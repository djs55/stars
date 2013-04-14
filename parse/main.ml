open Core.Std
open Async.Std

let stdout_writer = Lazy.force Writer.stdout
let log fmt = Printf.ksprintf (Writer.write stdout_writer) fmt

(* based on the Command example: *)
let uses_async : (unit -> int Deferred.t, unit -> unit) Command.Spec.t =
  Command.Spec.step (fun finished () ->
    upon (finished ()) Shutdown.shutdown;
    let () = never_returns (Scheduler.go ()) in
    ())

let spinner = [| '|'; '/'; '-'; '\\' |]

let command =
  Command.basic ~summary:"parse the HYG star database"
    Command.Spec.(empty +> anon ("FILE" %: string) ++ uses_async)
    (fun path () ->
      Reader.with_file path ~f:(fun r ->
        let rec loop sofar =
          Reader.read_line r
          >>= function
          | `Ok line ->
            let s = Star.of_string line in
            let sofar = match s with None -> sofar | Some _ -> sofar + 1 in
            if sofar mod 10000 = 0
            then log "\r[%c] %10d" (spinner.( (sofar / 10000) mod (Array.length spinner))) sofar;
            loop sofar
          | `Eof ->
            log "\nRead a total of %d valid records.\n" sofar; 
            return () in
        loop 0
      )
      >>= fun () ->
      return 0
    )

let () = Exn.handle_uncaught ~exit:true (fun () -> Command.run command)

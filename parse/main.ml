open Core.Std
open Async.Std

let stdout_writer = Lazy.force Writer.stdout
let log s = Writer.write stdout_writer s

(* based on the Command example: *)
let uses_async : (unit -> int Deferred.t, unit -> unit) Command.Spec.t =
  Command.Spec.step (fun finished () ->
    upon (finished ()) Shutdown.shutdown;
    let () = never_returns (Scheduler.go ()) in
    ())

let command =
  Command.basic ~summary:"parse the HYG star database"
    Command.Spec.(empty +> anon ("FILE" %: string) ++ uses_async)
    (fun path () ->
      Reader.with_file path ~f:(fun r ->
        let rec loop () =
          Reader.read_line r
          >>= function
          | `Ok line ->
            let s = Star.of_string line in
            let txt = match s with None -> "None" | Some s -> Star.to_string s in
            Writer.write (Lazy.force Writer.stdout) (txt ^ "\n");
            loop ()
          | `Eof ->
            return () in
        loop ()
      )
      >>= fun () ->
      return 0
    )

let () = Exn.handle_uncaught ~exit:true (fun () -> Command.run command)

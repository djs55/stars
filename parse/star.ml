
(* StarID,HIP,HD,HR,Gliese,BayerFlamsteed,ProperName,RA,Dec,Distance,PMRA,PMDec,RV,Mag,AbsMag,Spectrum,ColorIndex,X,Y,Z,VX,VY,VZ *)

type coords = {
  x: float;
  y: float;
  z: float;
  vx: float;
  vy: float;
  vz: float;
}

type t = {
  name: string;
  coords: coords;
}

let of_string x = match Re_str.(split_delim (regexp "[ \t]*,[ \t]*")) x with
  | starid :: hip :: hd :: hr :: gliese :: bayerflamsteed :: propername :: ra :: dec :: distance :: pmra :: pmdec :: rv :: mag :: absmag :: spectrum :: colorindex :: x :: y :: z :: vx :: vy :: vz :: [] ->
    begin try
      let coords = {
          x = float_of_string x;
          y = float_of_string y;
          z = float_of_string z;
          vx = float_of_string vx;
          vy = float_of_string vy;
          vz = float_of_string vz;
        } in
      Some { name = propername; coords }
    with _ -> None end
  | _ -> None

let to_string x = Printf.sprintf "%s,%f,%f,%f,%f,%f,%f" x.name x.coords.x x.coords.y x.coords.z x.coords.vx x.coords.vy x.coords.vz

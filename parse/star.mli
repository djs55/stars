
type coords = {
  x: float;
  y: float;
  z: float;
  vx: float;
  vy: float;
  vz: float;
}
(** position and velocity relative to Sol *)

type t = {
  name: string;   (** proper name e.g. 'Sol' *)
  coords: coords;
}
(** a single star *)

val of_string: string -> t option

val to_string: t -> string

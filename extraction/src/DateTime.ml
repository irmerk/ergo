(*
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *)

(** Native OCaml support for the Ergo DateTime library *)

open CalendarLib

(** Misc *)
let undefined_error op =
  raise (Failure ("Operation " ^ op ^ " not defined in REPL"))

(** Parse/Print *)
let lift_error fcont f x =
  begin try f x with
  | _ -> fcont x
  end
let rec lift_error_map fl fe =
  begin match fl with
  | [] -> fe
  | f::morefl ->
      lift_error (lift_error_map morefl fe) f
  end
type format =
  | FDate of string
  | FDateTime of string
let f_of_format fmt =
  begin match fmt with
  | FDateTime s ->
      (fun x ->
         Printer.Calendar.from_fstring s x)
  | FDate s ->
      (fun x ->
         let d = Printer.Date.from_fstring s x in
         Calendar.create d (Time.lmake ()))
  end
let multi_parse fl fe x =
  lift_error_map (List.map f_of_format fl) fe x

let iso8610 =
  [ FDate "%Y-%m-%d";
    FDate "%Y%m%d";
    FDateTime "%Y-%m-%dT%H:%M:%S";
    FDateTime "%Y-%m-%d %H:%M:%S";
    FDateTime "%Y-%m-%dT%H:%M:%S%:z";
    FDateTime "%Y-%m-%d %H:%M:%S%:z";
    FDate "%d %b %Y";
    FDate "%d %b %y";
    FDateTime "%d %b %y %H:%M:%S";
    FDateTime "%d %b %Y %H:%M:%S";
    FDateTime "%d %b %y %H:%M:%S %z";
    FDateTime "%d %b %Y %H:%M:%S %z";
    FDate "%a %d %b %Y";
    FDate "%a %d %b %y";
    FDateTime "%a %d %b %y %H:%M:%S";
    FDateTime "%a %d %b %Y %H:%M:%S";
    FDateTime "%a %d %b %y %H:%M:%S %z";
    FDateTime "%a %d %b %Y %H:%M:%S %z";
    FDate "%a, %d %b %Y";
    FDate "%a, %d %b %y";
    FDateTime "%a, %d %b %y %H:%M:%S";
    FDateTime "%a, %d %b %Y %H:%M:%S";
    FDateTime "%a, %d %b %y %H:%M:%S %z";
    FDateTime "%a, %d %b %Y %H:%M:%S %z"; ]

(** Duration *)
type duration = Calendar.Period.t
let duration_eq (d1:duration) (d2:duration) : bool = Calendar.Period.equal d1 d2
let duration_amount (x:duration) : int = Calendar.Time.Period.to_seconds (Calendar.Period.to_time x)
let duration_to_string (x:duration) : string = "_" (* XXX To be figured out *)
let duration_from_string (x:string) : duration = undefined_error "duration_from_string"

(** Period *)
type period = Calendar.Period.t

let period_eq (d1:period) (d2:period) : bool = Calendar.Period.equal d1 d2
let period_to_string (x:duration) : string = "_" (* XXX To be figured out *)
let period_from_string (x:string) : period = undefined_error "period_from_string"

(** DateTime *)
type dateTime = Calendar.t

(** Initial *)
let now () : dateTime = Calendar.now()

(** Serialize/deserialize *)
let error_dt (x:string) : dateTime = Calendar.lmake 0 ()
let from_string (x:string) : dateTime =
  multi_parse iso8610 error_dt x
let to_string (x:dateTime) : string =
  Printer.Calendar.sprint "%Y-%m-%d %H:%M:%S%:z" x

(** Components *)
let get_second (x:dateTime) : int = Calendar.Time.second (Calendar.to_time x)
let get_minute (x:dateTime) : int = Calendar.Time.minute (Calendar.to_time x)
let get_hour (x:dateTime) : int = Calendar.Time.hour (Calendar.to_time x)
let get_day (x:dateTime) : int = Calendar.day_of_month x
let get_week (x:dateTime) : int = Calendar.week x
let get_month (x:dateTime) : int = Date.int_of_month (Calendar.month x)
let get_quarter (x:dateTime) : int = ((get_month x) / 3) + 1
let get_year (x:dateTime) : int = Calendar.year x

(** Comparisons *)
let eq (x1:dateTime) (x2:dateTime) : bool = Calendar.compare x1 x2 = 0
let is_before (x1:dateTime) (x2:dateTime) : bool = Calendar.compare x1 x2 < 0
let is_after (x1:dateTime) (x2:dateTime) : bool = Calendar.compare x1 x2 > 0

(** Arithmetics *)
let diff (x1:dateTime) (x2:dateTime) : duration = Calendar.sub x1 x2
let diff_days (x1:dateTime) (x2:dateTime) : float =
  let d = Calendar.Period.to_date (diff x1 x2) in
  let d = Date.Period.nb_days d in
  float_of_int d
let diff_seconds (x1:dateTime) (x2:dateTime) : float =
  let t = Calendar.Period.to_time (diff x1 x2) in
  Time.Second.to_float (Time.Period.to_seconds t)

let add (x1:dateTime) (d1:duration) : dateTime = Calendar.add x1 d1
let subtract (x1:dateTime) (d1:duration) : dateTime = Calendar.rem x1 d1

let start_of_day (x1:dateTime) = undefined_error "start_of_day"
let start_of_week (x1:dateTime) = undefined_error "start_of_week"
let start_of_month (x1:dateTime) = undefined_error "start_of_month"
let start_of_quarter (x1:dateTime) = undefined_error "start_of_quarter"
let start_of_year (x1:dateTime) = undefined_error "start_of_year"

let end_of_day (x1:dateTime) = undefined_error "end_of_day"
let end_of_week (x1:dateTime) = undefined_error "end_of_week"
let end_of_month (x1:dateTime) = undefined_error "end_of_month"
let end_of_quarter (x1:dateTime) = undefined_error "end_of_quarter"
let end_of_year (x1:dateTime) = undefined_error "end_of_year"

let duration_seconds (x:int) = undefined_error "duration_seconds"
let duration_minutes (x:int) = undefined_error "duration_minutes"
let duration_hours (x:int) = undefined_error "duration_hours"
let duration_days (x:int) = Calendar.Period.day x
let duration_weeks (x:int) = undefined_error "duration_weeks"
let duration_years (x:int) = Calendar.Period.year x

let period_days (x:int) = Calendar.Period.day x
let period_weeks (x:int) = undefined_error "period_weeks"
let period_months (x:int) = Calendar.Period.month x
let period_years (x:int) = Calendar.Period.year x
let period_quarters (x:int) = Calendar.Period.month (x * 3)

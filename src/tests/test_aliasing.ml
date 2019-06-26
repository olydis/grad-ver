open OUnit2
open Core
open Ast
open Aliasing
open Functools
open Utility

open Test_utility

let makeAliasingContextTest : AliasingContext.t -> AliasingContext.t -> test_fun =
  makeEqualityTest ~cmp:AliasingContext.equal ~sexp_of_t:sexp_of_aliasingcontext

let makeAliasPropSetTest : AliasPropSet.t -> AliasPropSet.t -> test_fun =
  makeEqualityTest ~cmp:AliasPropSet.equal ~sexp_of_t:AliasPropSet.sexp_of_t

let ofId   (s:string) : ObjectValue.t = ObjectValue.of_objectvalue @@ Value(Object s)
let ofInt  (i:int)    : ObjectValue.t = ObjectValue.of_objectvalue @@ Value(Int(Int32.of_int_exn i))
let ofBool (b:bool)   : ObjectValue.t = ObjectValue.of_objectvalue @@ Value(Bool b)
let ofL  : ObjectValue.t list -> AliasProp.t = AliasProp.of_list
let ofLL : ObjectValue.t list list -> AliasPropSet.t = aliaspropset_of_objectvalue_list_list

(*--------------------------------------------------------------------------------------------------------------------------*)
(* context equality *)
(*--------------------------------------------------------------------------------------------------------------------------*)

module Equality =
struct
  let suite : test =
    "equality" >::: [
      "AliasPropSet.from_list" >::: [
        "from_list [] = empty" >:: makeAliasPropSetTest
          (AliasPropSet.of_list [])
          (AliasPropSet.empty)
      ]
    ]
end

(*--------------------------------------------------------------------------------------------------------------------------*)
(* propositional entailment *)
(*--------------------------------------------------------------------------------------------------------------------------*)

module Entailment =
struct
  let assert_entails     ps p ctxt = assert_bool "entails"            @@ AliasProp.entails ps p
  let assert_not_entails ps p ctxt = assert_bool "not entails" @@ not @@ AliasProp.entails ps p

  let suite : test =
    "(alias)propositional entailment" >::: [
      "{ } |- { } " >:: assert_entails
        (AliasPropSet.of_list[])
        (AliasProp.of_list[]);
      "{ } not|- aliased{o1,o2}" >:: assert_not_entails
        (AliasPropSet.of_list[])
        (AliasProp.of_list[ ofId"o1";ofId"o2" ]);
      "{ aliased{o1,o2} } |- aliased{ }" >:: assert_entails
        (AliasPropSet.of_list[ AliasProp.of_list[ ofId"o1";ofId"o2" ] ])
        (AliasProp.of_list[]);
    ]
end

(*--------------------------------------------------------------------------------------------------------------------------*)
(* merging *)
(*--------------------------------------------------------------------------------------------------------------------------*)

module Merging =
struct
  let empty : AliasingContext.t = {
    scope=Scope 0; parent=None; children=[];
    props=AliasPropSet.empty;
  }

  let single : AliasingContext.t = {
    scope=(Scope 0); parent=None; children=[];
    props=(ofLL[ [ofId"o1"; ofId"o2"] ]);
  }

  let suite : test =
    "merging" >::: [
      "union" >::: [
        "empty union empty = empty" >:: makeAliasingContextTest (AliasingContext.union empty empty) empty;
        (* "C union empty = C"         >:: makeAliasingContextTest (AliasingContext.union empty single) single; *)
        (* "C union C = C"             >:: makeAliasingContextTest (AliasingContext.union single single) single; *)
      ];
      "inter" >::: [
        (* "empty inter empty = empty" >:: makeAliasingContextTest (AliasingContext.inter empty empty) empty; *)
        (* "C inter empty = empty"     >:: makeAliasingContextTest (AliasingContext.inter single empty) empty; *)
      ]
    ]
end

(*--------------------------------------------------------------------------------------------------------------------------*)
(* construction *)
(*--------------------------------------------------------------------------------------------------------------------------*)

module Construction =
struct
  let suite : test =
    "construction" >::: [
        (* TODO *)
    ]
end

(*--------------------------------------------------------------------------------------------------------------------------*)
(* suite *)
(*--------------------------------------------------------------------------------------------------------------------------*)

let suite : test =
  "aliasing context" >::: [
    Equality.suite;
    Entailment.suite;
    Merging.suite;
    Construction.suite;
  ]
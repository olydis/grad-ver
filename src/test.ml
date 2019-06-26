open OUnit2
open Core
open Test_utility

(* open Ast_pp
open Ast_types
open Ast
open Utility
open Wellformed
open Aliasing
open Framing *)

(*--------------------------------------------------------------------------------------------------------------------------*)
(* unit test suite *)
(*--------------------------------------------------------------------------------------------------------------------------*)

let suite =
  "svlrp" >:::
  [ Test_ast.suite
  ; Test_formula.suite
  ; Test_wellformed.suite
  ; Test_aliasing.suite
  ; Test_framing.suite ]

(*--------------------------------------------------------------------------------------------------------------------------*)
(* main *)

let _ =
  print_endline "+============================================================================+";
  print_endline "|==/                                                                      \\==|";
  print_endline "|=|                              >[svlrp]<                                 |=|";
  print_endline "|=|                           unit test suite                              |=|";
  print_endline "|==\\                                                                      /==|";
  print_endline "+============================================================================+";
  run_test_tt_main suite
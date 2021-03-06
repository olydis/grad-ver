
type ident

val identifier : string -> ident
val matchIdent : ident -> ident -> bool
val name : ident -> string
module IdentMap : Core.Map.S

type typ =
  | Cls of ident
  | Int
  | Top
  | Any

type expop = Ast_types.expop =
  | Plus
  | Minus
  | Times
  | Div

type cmpop = Ast_types.cmpop =
  | Neq
  | Eq
  | Lt
  | Gt
  | Le
  | Ge

type vl =
  | Nil
  | Num of int
  | C
  | Result

and expr =
  | Binop of expr * expop * expr
  | FieldAccess of expr * ident
  | Val of vl
  | Var of ident
  | Old of ident

and formula =
  | Cmpf of expr * cmpop * expr
  | Alpha of ident * expr list
  | Access of expr * ident
  | Sep of formula * formula

type phi =
  | Concrete of formula
  | Grad of formula

type contract = {
  requires : phi;
  ensures : phi;
}

type methodCall = {
  target : ident;
  base : ident;
  methodname : ident;
  args : ident list;
}

type ifthen = {
  left : ident;
  cmp : cmpop;
  right : ident;
  thenClause : stmt;
  elseClause : stmt;
}

and stmt =
  | Skip
  | Seq of stmt * stmt
  | Declare of typ * ident
  | Assign of ident * expr
  | IfThen of ifthen
    (* x.f = y *)
  | Fieldasgn of ident * ident * ident
    (* x := new C *)
  | NewObj of ident * ident
  | Call of methodCall
  | Assert of formula
  | Release of formula
  | Hold of formula * stmt

type absPred = {
  name : ident;
  args : ident list;
  body : phi;
}

type methd = {
  name : ident;
  out_type : typ;
  args : (typ * ident) list;
  dynamic : contract;
  static : contract;
  body : stmt;
}

type cls = {
  name : ident;
  super : ident;
  fields : (typ * ident) list;
  abspreds : absPred list;
  methods : methd list;
}

type program = {
  classes : cls list;
  stmts : stmt list;
}

val pp_binop : expop -> string
val pp_cmpop : cmpop -> string
val pp_exp : expr -> string
val pp_stmt : stmt -> string
val pp_formula : formula -> string


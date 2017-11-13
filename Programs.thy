theory Programs
  imports Main Syntax Semantics "~~/src/HOL/Library/Sublist" "~~/src/HOL/IMP/Star" "~~/src/HOL/Eisbach/Eisbach_Tools"
begin
    
abbreviation a where "a \<equiv> Var ''a''"
abbreviation b where "b \<equiv> Var ''b''"
abbreviation c where "c \<equiv> Var ''c''"
abbreviation d where "d \<equiv> Var ''d''"
abbreviation e where "e \<equiv> Var ''e''"
abbreviation f where "f \<equiv> Var ''f''"
abbreviation w where "w \<equiv> Var ''w''"
abbreviation x where "x \<equiv> Var ''x''"
abbreviation y where "y \<equiv> Var ''y''"
abbreviation z where "z \<equiv> Var ''z''"


method condition_split = (
  match premises in 
    I: "(if P then _ else _) = Some _" for P \<Rightarrow> \<open>cases P\<close>
, auto)


method leaf_elim_loop for m :: state_pool and stpool :: state_pool and l :: control_path uses I = (
  match (m) in 
    "Map.empty" \<Rightarrow> \<open> fail \<close> \<bar>
    "m'((p :: control_path) \<mapsto> (_ :: state))" for m' p \<Rightarrow> 
        \<open>((insert I, (drule leaf_elim[of stpool l p]), auto); leaf_elim_loop m' stpool l I: I)\<close>
)

method leaf_elim_search = (
  match premises in 
    I: "leaf stpool lf" for stpool lf \<Rightarrow> \<open>(leaf_elim_loop stpool stpool lf I: I)\<close>
)

method topo_solve = 
  (
    (erule star.cases, auto),
    (simp add: recv_sites_def send_sites_def leaf_def, auto),
    (condition_split+),
    (erule concur_step.cases, auto),
    (erule seq_step.cases),
    (condition_split | leaf_elim_search)+
  )

definition prog_one where 
  "prog_one = 
    LET a = CHAN \<lparr>\<rparr> in
    LET b = SPAWN (
      LET c = CHAN \<lparr>\<rparr> in
      LET d = SEND EVT a b in
      LET w = SYNC d in
      RESULT d
    ) in
    LET e = RECV EVT a in
    LET f = SYNC e in
    RESULT f
  "
 
theorem prog_one_properties: "single_receiver prog_one a"
  apply (simp add: single_receiver_def single_side_def state_pool_possible_def prog_one_def, auto)
  apply topo_solve+
done


theorem prog_one_properties2: "single_sender prog_one a"
  apply (simp add: single_sender_def single_side_def state_pool_possible_def prog_one_def, auto)
  apply topo_solve+
done

definition prog_two where 
  "prog_two = 
    LET a = CHAN \<lparr>\<rparr> in
    LET b = SPAWN (
      LET c = CHAN \<lparr>\<rparr> in
      LET x = SEND EVT a c in
      LET y = SYNC x in
      LET z = RECV EVT c in
      RESULT z
    ) in
    LET d = RECV EVT a in
    LET e = SYNC d in
    LET f = SEND EVT e b in
    LET w = SYNC f in
    RESULT w
  "
    
definition prog_three where 
  "prog_three = 
    .LET a = .CHAN \<lparr>\<rparr> in
    .LET b = .SPAWN (
      .LET c = .CHAN \<lparr>\<rparr> in
      .LET x = .SEND EVT .a .c in
      .LET y = .SYNC .x in
      .LET z = .RECV EVT .c in
      .z
    ) in
    .LET d = .RECV EVT .a in
    .LET e = .SYNC .d in
    .LET f = .SEND EVT .e .b in
    .LET w = .SYNC .f in
    .w
  "
  
value "normalize prog_three"
  
definition prog_four where
  "prog_four = 
    .LET a = .FN f x .
      .CASE .x
      LEFT b |> .RIGHT (.APP .f .b)
      RIGHT b |> .LEFT .b
    in
    .APP .a (.LEFT (.LEFT (.LEFT (.RIGHT .\<lparr>\<rparr>))))
  "
  
value "normalize prog_four"

inductive abc :: "nat \<Rightarrow> nat \<Rightarrow> bool" where 
  abceq: "
    ((qqq :: nat) = (qqqq :: nat)) \<Longrightarrow>
    (abc qqq qqqq)
  "


lemma TrueI: True
  unfolding True_def 
apply (rule refl)
done



inductive sorted :: "('a \<Rightarrow> 'a \<Rightarrow> bool) \<Rightarrow> 'a list \<Rightarrow> bool" where
Nil : "sorted P Nil" |
Single : "sorted P (Cons xx Nil)" |
Cons : "P xx yy \<Longrightarrow> sorted P (Cons yy yys) \<Longrightarrow> sorted P (Cons xx (Cons yy yys))"

datatype nat =
  Z | S nat

inductive lte :: "nat \<Rightarrow> nat \<Rightarrow> bool" where
  Eq : "lte n n" |
  Lt : "lte n1 n2 \<Longrightarrow> lte n1 (S n2) "

lemma "sorted lte [Z, (S Z), (S Z), (S (S (S Z)))]"
 apply (rule Cons)
  apply (rule Lt)
  apply (rule Eq)
 apply (rule Cons)
  apply (rule Eq)
 apply (rule Cons)
  apply (rule Lt)
  apply (rule Lt)
  apply (rule Eq)
 apply (rule Single)
done

definition Xll :: "('a \<Rightarrow> bool) \<Rightarrow> bool"  (binder "x$" 10)
  where "Xll P \<equiv> (P = (\<lambda>x. True))"

value "x$ P . P"
value "All (\<lambda> P . P)"

end

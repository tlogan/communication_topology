theory Sound_Framework
  imports Main Syntax Dynamic_Semantics Static_Semantics
      Static_Framework
      "~~/src/HOL/Eisbach/Eisbach_Tools"
begin

inductive is_super_stack :: "cont list \<Rightarrow> exp \<Rightarrow> bool" where
  Exp: "
    is_super_exp e e' \<Longrightarrow>
    is_super_stack (\<langle>x, e, \<rho>\<rangle> # \<kappa>) e'
  " |
  Stack: "
    is_super_stack \<kappa> e' \<Longrightarrow>
    is_super_stack (\<langle>x, e, \<rho>\<rangle> # \<kappa>) e'
  "


lemma isnt_exp_sound_generalized: "
  \<E> \<rightarrow>* \<E>' \<Longrightarrow> 
  \<E> \<pi> = Some (\<langle>e;\<rho>;\<kappa>\<rangle>) \<Longrightarrow>
  \<E>' \<pi>' = Some (\<langle>e';\<rho>';\<kappa>'\<rangle>) \<Longrightarrow>
  leaf \<E> \<pi> \<Longrightarrow>
  prefix \<pi> \<pi>' \<Longrightarrow>
  is_super_exp e e' \<or> is_super_stack \<kappa> e'
"
proof -
  assume "\<E> \<pi> = Some (\<langle>e;\<rho>;\<kappa>\<rangle>)" "\<E>' \<pi>' = Some (\<langle>e';\<rho>';\<kappa>'\<rangle>)" 
  and "leaf \<E> \<pi>" "prefix \<pi> \<pi>'"

  assume "\<E> \<rightarrow>* \<E>'" then
  have "
    \<forall> \<pi> e \<rho> \<kappa> \<pi>' e' \<rho>' \<kappa>' .
      \<E> \<pi> = Some (\<langle>e;\<rho>;\<kappa>\<rangle>) \<longrightarrow>
      \<E>' \<pi>' = Some (\<langle>e';\<rho>';\<kappa>'\<rangle>) \<longrightarrow>
      leaf \<E> \<pi> \<longrightarrow>
      prefix \<pi> \<pi>' \<longrightarrow>
      is_super_exp e e' \<or> is_super_stack \<kappa> e'
  "
  proof (induction rule: star.induct)
    case (refl \<E>)
    show ?case
      by (metis is_super_exp.simps leaf.cases option.distinct(1) option.inject prefix_order.dual_order.order_iff_strict state.inject)
  next
    case (step E1 E2 E3)
    {
      fix \<pi>1 e1 \<rho>1 \<kappa>1 \<pi>3 e3 \<rho>3 \<kappa>3
      assume "E1 \<pi>1 = Some (\<langle>e1;\<rho>1;\<kappa>1\<rangle>)" "E3 \<pi>3 = Some (\<langle>e3;\<rho>3;\<kappa>3\<rangle>)" 
      assume "leaf E1 \<pi>1" "prefix \<pi>1 \<pi>3"
      have "is_super_exp e1 e3 \<or> is_super_stack \<kappa>1 e3" sorry
    } then
    show ?case by blast
  qed
  with \<open>\<E> \<pi> = Some (\<langle>e;\<rho>;\<kappa>\<rangle>)\<close> \<open>\<E>' \<pi>' = Some (\<langle>e';\<rho>';\<kappa>'\<rangle>)\<close> \<open>leaf \<E> \<pi>\<close> \<open>prefix \<pi> \<pi>'\<close>

  show "is_super_exp e e' \<or> is_super_stack \<kappa> e'" by blast

qed

lemma isnt_exp_sound: "
  [[] \<mapsto> \<langle>e\<^sub>0;Map.empty;[]\<rangle>] \<rightarrow>* \<E>' \<Longrightarrow>
  \<E>' \<pi>' = Some (\<langle>e';\<rho>';\<kappa>'\<rangle>) \<Longrightarrow>
  is_super_exp e\<^sub>0 e'
"
sorry


end

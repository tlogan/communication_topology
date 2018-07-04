theory Sound_Communication_Analysis_A
  imports 
    Main
    Syntax 
    Dynamic_Semantics Static_Semantics Sound_Semantics
    Static_Framework Sound_Framework
    Dynamic_Communication_Analysis 
    Static_Communication_Analysis Static_Communication_Analysis_A
    Sound_Communication_Analysis
begin

lemma static_paths_of_same_run_inclusive_base: "
  E0 = [[] \<mapsto> \<langle>e;Map.empty;[]\<rangle>] \<Longrightarrow>
  E0 \<pi>1 \<noteq> None \<Longrightarrow>
  E0 \<pi>2 \<noteq> None \<Longrightarrow>
  paths_congruent \<pi>1 path1 \<Longrightarrow>
  paths_congruent \<pi>2 path2 \<Longrightarrow>
  path1 \<asymp> path2
"
proof -
  assume 
    H1: "E0 = [[] \<mapsto> \<langle>e;Map.empty;[]\<rangle>]" and
    H2: "E0 \<pi>1 \<noteq> None" and
    H3: "E0 \<pi>2 \<noteq> None" and
    H4: "paths_congruent \<pi>1 path1" and
    H5: "paths_congruent \<pi>2 path2"
  
  from H4
  show "path1 \<asymp> path2"
  proof cases
    case Empty
    then show ?thesis
      by (simp add: Prefix1)
  next
    case (Next \<pi> path x)
    then show ?thesis
      using H1 H2 by auto
  next
    case (Call \<pi> path x)
    then show ?thesis
      using H1 H2 by auto
  next
    case (Spawn \<pi> path x)
    then show ?thesis
      using H1 H2 by auto
  next
    case (Return \<pi> x \<pi>' path y)
    then show ?thesis
      using H1 H2 by auto
  qed 
qed

lemma paths_equal_implies_paths_inclusive: "
  path1 = path2 \<Longrightarrow> path1 \<asymp> path2 
"
by (simp add: Prefix2)

lemma paths_cong_preserved_under_reduction: "
  paths_congruent (\<pi> ;; l) (path @ [n]) \<Longrightarrow>
  paths_congruent \<pi> path"
using paths_congruent.cases by fastforce


lemma path_state_preserved_for_non_leaf: "
(E, H) \<rightarrow> (E', H') \<Longrightarrow>
E' (\<pi> ;; l) = Some \<sigma> \<Longrightarrow>
\<not> leaf E \<pi> \<Longrightarrow>
E (\<pi> ;; l) = Some \<sigma>
"
apply (erule concur_step.cases; auto; (erule seq_step.cases; auto)?)
  apply presburger+
  apply (metis append1_eq_conv fun_upd_other)
  apply (metis butlast_snoc fun_upd_apply)
done


lemma equality_preserved_under_congruent': "
  paths_congruent \<pi>1 path \<Longrightarrow>
  \<forall> \<pi>2 .  paths_congruent \<pi>2 path \<longrightarrow> \<pi>1 = \<pi>2
"
apply (erule paths_congruent.induct)
  using paths_congruent.cases apply blast
apply (rule allI, rule impI)
apply (drule_tac x = "butlast \<pi>2" in spec)
apply (rotate_tac)
apply (erule paths_congruent.cases; auto)
apply (rule allI, rule impI)
apply (drule_tac x = "butlast \<pi>2" in spec)
apply (rotate_tac)
apply (erule paths_congruent.cases; auto)
apply (rule allI, rule impI)
apply (drule_tac x = "butlast \<pi>2" in spec)
apply (rotate_tac)
apply (erule paths_congruent.cases; auto)
apply (rule allI, rule impI)
apply (drule_tac x = "butlast \<pi>2" in spec)
apply (rotate_tac)
apply (erule paths_congruent.cases; auto)
  apply (simp add: butlast_append)+
done


lemma equality_preserved_under_congruent: "
  path1 = path2 \<Longrightarrow>
  paths_congruent \<pi>1 path1 \<Longrightarrow>
  paths_congruent \<pi>2 path2 \<Longrightarrow>
  \<pi>1 = \<pi>2
"
by (simp add: equality_preserved_under_congruent')



lemma paths_congruent_preserved_under_reduction: "
  paths_congruent \<pi>1 path1 \<Longrightarrow>
  paths_congruent (butlast \<pi>1) (butlast path1) 
"
apply (erule paths_congruent.cases; auto)
  apply (simp add: paths_congruent.Empty)
  apply (simp add: butlast_append)
done

lemma strict_prefix_preserved: "
paths_congruent \<pi>1 path1 \<Longrightarrow>
paths_congruent \<pi> path \<Longrightarrow>
strict_prefix path1 (path @ [n]) \<Longrightarrow>
\<not> strict_prefix \<pi>1 (\<pi> ;; l) \<Longrightarrow>
strict_prefix (butlast path1) path
"
apply (erule paths_congruent.cases; auto)
  using prefix_bot.bot.not_eq_extremum apply blast
  using prefix_order.order.strict_implies_order prefix_snocD apply fastforce
  using prefix_order.dual_order.strict_implies_order prefix_snocD apply fastforce
  apply (metis prefix_snoc prefix_snocD strict_prefixE)
  apply (metis prefix_snoc prefix_snocD strict_prefixE)
done


lemma prefix_preserved_under_congruent_paths': "

paths_congruent \<pi>2 path2 \<Longrightarrow>
\<forall> \<pi>1 path1 .
paths_congruent \<pi>1 path1 \<longrightarrow>
prefix path1 path2 \<longrightarrow>
prefix \<pi>1 \<pi>2
"
apply (erule paths_congruent.induct; auto)
  apply (simp add: equality_preserved_under_congruent paths_congruent.Empty)
  apply (simp add: equality_preserved_under_congruent paths_congruent.Next)
  apply (simp add: Call equality_preserved_under_congruent)
  apply (simp add: equality_preserved_under_congruent' paths_congruent.Spawn)
  apply (metis (no_types, hide_lams) append_Cons append_assoc equality_preserved_under_congruent paths_congruent.Return prefix_order.eq_iff)
  apply (metis append_Cons prefix_append)
done

lemma prefix_preserved_under_congruent_paths: "
paths_congruent \<pi>2 path2 \<Longrightarrow>
paths_congruent \<pi>1 path1 \<Longrightarrow>
prefix path1 path2 \<Longrightarrow>
prefix \<pi>1 \<pi>2
"
by (simp add: prefix_preserved_under_congruent_paths')



lemma not_strict_prefix_preserved_under_congruent_paths: "
\<not> strict_prefix \<pi>1 \<pi>2 \<Longrightarrow>
paths_congruent \<pi>1 path1 \<Longrightarrow>
paths_congruent \<pi>2 path2 \<Longrightarrow>
\<not> strict_prefix path1 path2
"
apply (erule paths_congruent.cases; auto)
apply (erule paths_congruent.cases; auto)
  using prefix_bot.bot.not_eq_extremum apply blast
  using prefix_bot.bot.not_eq_extremum apply blast
  using prefix_bot.bot.not_eq_extremum apply blast
  using prefix_bot.bot.not_eq_extremum apply blast
  apply (smt Nil_is_append_conv append_butlast_last_id paths_congruent.Next paths_congruent_preserved_under_reduction prefix_def prefix_order.dual_order.order_iff_strict prefix_order.less_irrefl prefix_preserved_under_congruent_paths prefix_snoc prefix_snocD)
  apply (smt Nil_is_append_conv append_butlast_last_id paths_congruent.Call paths_congruent_preserved_under_reduction prefix_def prefix_order.dual_order.order_iff_strict prefix_order.less_irrefl prefix_preserved_under_congruent_paths prefix_snoc prefix_snocD)
  apply (smt Nil_is_append_conv append_butlast_last_id paths_congruent.Spawn paths_congruent_preserved_under_reduction prefix_def prefix_order.dual_order.order_iff_strict prefix_order.less_irrefl prefix_preserved_under_congruent_paths prefix_snoc prefix_snocD)
  using Nil_is_append_conv append_butlast_last_id paths_congruent.Return paths_congruent_preserved_under_reduction prefix_def prefix_order.dual_order.order_iff_strict prefix_order.less_irrefl prefix_preserved_under_congruent_paths prefix_snoc prefix_snocD
proof -
  fix \<pi> :: "control_label list" and x :: Syntax.var and \<pi>' :: "control_label list" and path :: "(node_label \<times> edge_label) list" and y :: Syntax.var
  assume a1: "\<pi>1 = \<pi> @ LCall x # (\<pi>' ;; LReturn y)"
  assume a2: "path1 = path @ [(NResult y, EReturn x)]"
  assume a3: "paths_congruent (\<pi> @ LCall x # \<pi>') path"
  assume a4: "balanced \<pi>'"
  assume a5: "paths_congruent \<pi>2 path2"
  assume a6: "strict_prefix (path @ [(NResult y, EReturn x)]) path2"
  assume a7: "\<not> strict_prefix (\<pi> @ LCall x # (\<pi>' ;; LReturn y)) \<pi>2"
  have f8: "paths_congruent \<pi>1 path1"
    using a4 a3 a2 a1 paths_congruent.Return by auto
  have "prefix path1 (butlast path2)"
    using a6 a2 by (metis (no_types) Nil_is_append_conv append_butlast_last_id append_self_conv list.distinct(1) prefix_order.dual_order.order_iff_strict prefix_snoc strict_prefixE')
  then show False
    using f8 a7 a6 a5 a2 a1 by (metis butlast.simps(2) butlast_append list.distinct(1) paths_congruent_preserved_under_reduction prefix_order.antisym prefix_order.dual_order.order_iff_strict prefix_preserved_under_congruent_paths prefixeq_butlast same_append_eq snoc_eq_iff_butlast)
qed


lemma spawn_point: "
  (E, H) \<rightarrow> (E', H') \<Longrightarrow>
  leaf E \<pi> \<Longrightarrow>
  E' (\<pi> ;; l1) = Some \<sigma>1 \<Longrightarrow>
  E' (\<pi> ;; l2) = Some \<sigma>2 \<Longrightarrow>
  l1 = l2 \<or> 
  (\<exists> x . l1 = (LNext x) \<and> l2 = (LSpawn x)) \<or>
  (\<exists> x . l1 = (LSpawn x) \<and> l2 = (LNext x))
"
apply (erule concur_step.cases; auto; (erule seq_step.cases; auto)?)
  apply (metis leaf.cases option.distinct(1) strict_prefixI')
  apply (metis leaf.cases option.distinct(1) strict_prefixI')
  apply (metis leaf.cases option.distinct(1) strict_prefixI')
  apply (metis leaf.cases option.distinct(1) strict_prefixI')
  apply (metis leaf.cases option.distinct(1) strict_prefixI')
  apply (metis leaf.cases option.distinct(1) strict_prefixI')
  apply (metis leaf.cases option.distinct(1) strict_prefixI')
  apply (metis (mono_tags, lifting) append1_eq_conv fun_upd_apply leaf.cases option.distinct(1) strict_prefixI')
  apply (smt butlast_snoc exp.inject(1) fun_upd_apply last_snoc leaf.cases option.distinct(1) option.inject state.inject strict_prefixI')
done


lemma asdf: "
paths_congruent \<pi> p \<Longrightarrow>
\<forall> \<pi>' x \<pi>'' y path n2.
\<pi> = (\<pi>' @ LCall x # (\<pi>'' ;; LReturn y)) \<longrightarrow> p = (path @ [n2]) \<longrightarrow>
paths_congruent (\<pi>' @ LCall x # \<pi>'') path \<longrightarrow>
balanced \<pi>'' \<longrightarrow>
(NResult y, EReturn x) = n2
"
apply (erule paths_congruent.induct)
  apply blast
  apply simp
  apply simp
  apply simp
apply (rule allI)+
apply (rule impI)+
apply auto
sledgehammer
sorry

lemma spawn_point_preserved_under_congruent_paths: "
l1 = l2 \<or> 
(\<exists> x . l1 = (LNext x) \<and> l2 = (LSpawn x)) \<or>
(\<exists> x . l1 = (LSpawn x) \<and> l2 = (LNext x)) \<Longrightarrow>
paths_congruent (\<pi> ;; l1) (path @ [n1]) \<Longrightarrow>
paths_congruent (\<pi> ;; l2) (path @ [n2]) \<Longrightarrow>
n1 = n2 \<or> 
(\<exists> x . n1 = (NLet x, ENext) \<and> n2 = (NLet x, ESpawn )) \<or>
(\<exists> x . n1 = (NLet x, ESpawn ) \<and> n2 = (NLet x, ENext))
"
apply (erule paths_congruent.cases; auto)
apply (erule paths_congruent.cases; auto)
apply (erule paths_congruent.cases; auto)
apply (erule paths_congruent.cases; auto)
apply (erule paths_congruent.cases; auto)
apply (erule paths_congruent.cases; auto)
sorry

lemma static_paths_of_same_run_inclusive_step: "
\<forall>\<pi>1 \<pi>2 path1 path2.
  E \<pi>1 \<noteq> None \<longrightarrow>
  E \<pi>2 \<noteq> None \<longrightarrow>
  paths_congruent \<pi>1 path1 \<longrightarrow> 
  paths_congruent \<pi>2 path2 \<longrightarrow> 
  path1 \<asymp> path2 \<Longrightarrow>
star_left op \<rightarrow> ([[] \<mapsto> \<langle>e;Map.empty;[]\<rangle>], {}) (E, H) \<Longrightarrow>
(E, H) \<rightarrow> (E', H') \<Longrightarrow>
E' \<pi>1 \<noteq> None \<Longrightarrow>
E' \<pi>2 \<noteq> None \<Longrightarrow>
paths_congruent \<pi>1 path1 \<Longrightarrow> 
paths_congruent \<pi>2 path2 \<Longrightarrow>
path1 \<asymp> path2 
"
proof ((case_tac "path1 = []"; (simp add: Prefix1)), (case_tac "path2 = []", (simp add: Prefix2)))
  assume 
    H1: "
      \<forall>\<pi>1. (\<exists>y. E \<pi>1 = Some y) \<longrightarrow>
      (\<forall>\<pi>2. (\<exists>y. E \<pi>2 = Some y) \<longrightarrow>
      (\<forall>path1. paths_congruent \<pi>1 path1 \<longrightarrow>
      (\<forall>path2. paths_congruent \<pi>2 path2 \<longrightarrow> 
        path1 \<asymp> path2)))" and
    H2: "star_left op \<rightarrow> ([[] \<mapsto> \<langle>e;Map.empty;[]\<rangle>], {}) (E, H)" and
    H3: "(E, H) \<rightarrow> (E', H')" and
    H4: "\<exists>y. E' \<pi>1 = Some y" and
    H5: "\<exists>y. E' \<pi>2 = Some y " and
    H6: "paths_congruent \<pi>1 path1" and
    H7: "paths_congruent \<pi>2 path2" and
    H8: "path1 \<noteq> []" and 
    H9: "path2 \<noteq> []"

  obtain \<sigma>1 where 
    H10: "E' \<pi>1 = Some \<sigma>1"
    using H4 by blast

  obtain \<sigma>2 where 
    H11: "E' \<pi>2 = Some \<sigma>2"
    using H5 by blast

  from H6
  obtain \<pi>1x l1 path1x n1 where
    H12: "\<pi>1x ;; l1 = \<pi>1" and
    H13: "path1x @ [n1] = path1" and
    H14: "paths_congruent \<pi>1x path1x"
    apply (rule paths_congruent.cases)
    using H8 by blast+

  from H7
  obtain \<pi>2x l2 path2x n2 where
    H15: "\<pi>2x ;; l2 = \<pi>2" and
    H16: "path2x @ [n2] = path2" and
    H17: "paths_congruent \<pi>2x path2x"
    apply (rule paths_congruent.cases)
    using H9 by blast+
 
  have H22: "paths_congruent (\<pi>1x ;; l1) (path1x @ [n1])"
    by (simp add: H12 H13 H6)

  have H23: "paths_congruent (\<pi>2x ;; l2) (path2x @ [n2])"
    by (simp add: H15 H16 H7)

  show "path1 \<asymp> path2"
  proof cases
    assume L1H1: "leaf E \<pi>1x"
    obtain \<sigma>1x where
      L1H2: "E \<pi>1x = Some \<sigma>1x" using L1H1 leaf.simps by auto
    show "path1 \<asymp> path2"
    proof cases
      assume L2H1: "leaf E \<pi>2x"
      obtain \<sigma>2x where
        L2H2: "E \<pi>2x = Some \<sigma>2x" using L2H1 leaf.simps by auto


      have L2H4: "\<not> strict_prefix \<pi>1x \<pi>2x"
        by (meson L1H1 L2H1 leaf.cases)
      have L2H5: "\<not> strict_prefix \<pi>2x \<pi>1x"
        by (meson L1H1 L2H1 leaf.cases)

      have L2H6: "\<not> strict_prefix path1x path2x"
        using H14 H17 L2H4 not_strict_prefix_preserved_under_congruent_paths by auto
      have L2H7: "\<not> strict_prefix path2x path1x"
        using H14 H17 L2H5 not_strict_prefix_preserved_under_congruent_paths by blast

      have L2H8: "path1x \<asymp> path2x"
        using H1 H14 H17 L1H2 L2H2 by blast

      show "path1 \<asymp> path2"
      proof cases
        assume L3H1: "path1x = path2x"

        have L3H3: "
          l1 = l2 \<or> 
          (\<exists> x . l1 = (LNext x) \<and> l2 = (LSpawn x)) \<or>
          (\<exists> x . l1 = (LSpawn x) \<and> l2 = (LNext x))" 
          by (smt H10 H11 H12 H14 H15 H16 H3 H7 L1H1 L2H4 L3H1 not_strict_prefix_preserved_under_congruent_paths prefix_snoc spawn_point strict_prefixI' strict_prefix_def)

        have L3H4: "
          n1 = n2 \<or> 
          (\<exists> x . n1 = (NLet x, ENext) \<and> n2 = (NLet x, ESpawn )) \<or>
          (\<exists> x . n1 = (NLet x, ESpawn ) \<and> n2 = (NLet x, ENext))" 
          using H22 H23 L3H3 spawn_point_preserved_under_congruent_paths by auto

        have L3H5: "path1x @ [n1] \<asymp> path1x @ [n2]"
          using L3H4 may_be_inclusive.intros(3) may_be_inclusive.intros(4) paths_equal_implies_paths_inclusive by blast
        show "path1 \<asymp> path2"
          using H13 H16 L3H1 L3H5 by auto
      next
        assume L3H1: "path1x \<noteq> path2x"
        show "path1 \<asymp> path2"
          using H13 H16 L2H6 L2H7 L2H8 L3H1 may_be_inclusive_preserved_under_unordered_double_extension strict_prefixI by blast
      qed
    next
      assume L2H1: "\<not> leaf E \<pi>2x"
      have L2H2: "E \<pi>2 = Some \<sigma>2"
        using H11 H15 H3 L2H1 path_state_preserved_for_non_leaf by blast
      have L2H3: "path1x \<asymp> path2"
        using H1 H14 H7 L1H2 L2H2 by blast

      have L2H8: "\<not> strict_prefix \<pi>1x \<pi>2"
        by (metis L1H1 L2H2 leaf.cases option.distinct(1))
      have L2H9: "\<not> strict_prefix path1x path2"
        using H14 H7 L2H8 not_strict_prefix_preserved_under_congruent_paths by blast
      show "path1 \<asymp> path2"
        by (metis H13 L2H3 L2H9 Prefix2 may_be_inclusive_preserved_under_unordered_extension prefix_prefix strict_prefix_def)
    qed

  next
    assume L1H1: "\<not> leaf E \<pi>1x"
      have L1H2: "E \<pi>1 = Some \<sigma>1"
        using H10 H12 H3 L1H1 path_state_preserved_for_non_leaf by blast
    show "path1 \<asymp> path2"

    proof cases
      assume L2H1: "leaf E \<pi>2x"
      obtain \<sigma>2x where
        L2H2: "E \<pi>2x = Some \<sigma>2x" using L2H1 leaf.simps by auto
      have L2H3: "path1 \<asymp> path2x"
        using H1 H17 H6 L1H2 L2H2 by blast
      have L2H8: "\<not> strict_prefix \<pi>2x \<pi>1"
        by (metis L1H2 L2H1 leaf.cases option.distinct(1))
      have L2H9: "\<not> strict_prefix path2x path1"
        using H17 H6 L2H8 not_strict_prefix_preserved_under_congruent_paths by auto
      show "path1 \<asymp> path2"
        by (metis H16 L2H3 L2H9 Prefix1 may_be_inclusive_commut may_be_inclusive_preserved_under_unordered_extension prefix_order.dual_order.not_eq_order_implies_strict prefix_prefix)
    next
      assume L2H1: "\<not> leaf E \<pi>2x"
      have L2H2: "E \<pi>2 = Some \<sigma>2"
        using H11 H15 H3 L2H1 path_state_preserved_for_non_leaf by blast
      show "path1 \<asymp> path2"
        using H1 H6 H7 L1H2 L2H2 by blast
    qed

  qed

qed

lemma static_paths_of_same_run_inclusive: "
  ([[] \<mapsto> \<langle>e;Map.empty;[]\<rangle>], {}) \<rightarrow>* (\<E>', H') \<Longrightarrow> 
  \<E>' \<pi>1 \<noteq> None \<Longrightarrow> 
  \<E>' \<pi>2 \<noteq> None \<Longrightarrow> 
  paths_congruent \<pi>1 path1 \<Longrightarrow>
  paths_congruent \<pi>2 path2 \<Longrightarrow>
  path1 \<asymp> path2
"
proof -
  assume
    H1: "([[] \<mapsto> \<langle>e;Map.empty;[]\<rangle>], {}) \<rightarrow>* (\<E>', H')" and
    H2: "\<E>' \<pi>1 \<noteq> None" and
    H3: "\<E>' \<pi>2 \<noteq> None" and
    H4: "paths_congruent \<pi>1 path1" and
    H5: "paths_congruent \<pi>2 path2"

  from H1 have
    "star_left (op \<rightarrow>) ([[] \<mapsto> \<langle>e;Map.empty;[]\<rangle>], {}) (\<E>', H')" by (simp add: star_implies_star_left)
  
  then obtain X0 X' where 
    H6: "X0 = ([[] \<mapsto> \<langle>e;Map.empty;[]\<rangle>], {})" 
        "X' = (\<E>', H')" and
    H7: "star_left (op \<rightarrow>) X0 X'" by auto

  from H7 have 
    H8: "
      \<forall> \<E>' H' \<pi>1 \<pi>2 path1 path2.
      X0 = ([[] \<mapsto> \<langle>e;Map.empty;[]\<rangle>], {}) \<longrightarrow> X' = (\<E>', H') \<longrightarrow>
      \<E>' \<pi>1 \<noteq> None \<longrightarrow>
      \<E>' \<pi>2 \<noteq> None \<longrightarrow>
      paths_congruent \<pi>1 path1 \<longrightarrow>
      paths_congruent \<pi>2 path2 \<longrightarrow>
      path1 \<asymp> path2
    "
  proof induction
    case (refl z)
    then show ?case
      using static_paths_of_same_run_inclusive_base by blast
  next
    case (step x y z)

    {
      fix \<E>' H' \<pi>1 \<pi>2 path1 path2
      assume 
        L2H1: "x = ([[] \<mapsto> \<langle>e;Map.empty;[]\<rangle>], {})" and
        L2H2: "z = (\<E>', H')" and
        L2H3: "\<E>' \<pi>1 \<noteq> None" and
        L2H4: "\<E>' \<pi>2 \<noteq> None" and
        L2H5: "paths_congruent \<pi>1 path1" and
        L2H6: "paths_congruent \<pi>2 path2"

      obtain \<E> H where 
        L2H7: "y = (\<E>, H)" by (meson surj_pair)

      from L2H1 L2H7 step.IH have 
        L2H8: "
          \<forall> \<pi>1 \<pi>2 path1 path2 . 
          \<E> \<pi>1 \<noteq> None \<longrightarrow>
          \<E> \<pi>2 \<noteq> None \<longrightarrow>
          paths_congruent \<pi>1 path1 \<longrightarrow> 
          paths_congruent \<pi>2 path2 \<longrightarrow> 
          path1 \<asymp> path2 "
        by blast

      have 
        "path1 \<asymp> path2"
        using L2H1 L2H2 L2H3 L2H4 L2H5 L2H6 L2H7 L2H8 static_paths_of_same_run_inclusive_step step.hyps(1) step.hyps(2) by blast
    }
    then show ?case by blast
  qed

  from H2 H3 H4 H5 H6(1) H6(2) H8 show 
    "path1 \<asymp> path2" by blast
qed

lemma is_send_path_implies_nonempty_pool: "
  is_send_path \<E> (Ch \<pi>C xC) \<pi> \<Longrightarrow> 
  \<E> \<pi> \<noteq> None
"
proof -
  assume H1: "is_send_path \<E> (Ch \<pi>C xC) \<pi>"
  
  then have
    H2: "
      \<exists> x\<^sub>y x\<^sub>e e\<^sub>n \<rho> \<kappa>. \<E> \<pi> = Some (\<langle>LET x\<^sub>y = SYNC x\<^sub>e in e\<^sub>n;\<rho>;\<kappa>\<rangle>) 
    " using is_send_path.simps by auto

  then show 
    "\<E> \<pi> \<noteq> None" by blast
qed

lemma send_static_paths_of_same_run_inclusive: "
  ([[] \<mapsto> \<langle>e;Map.empty;[]\<rangle>], {}) \<rightarrow>* (\<E>', H') \<Longrightarrow> 
  is_send_path \<E>' (Ch \<pi> xC) \<pi>1 \<Longrightarrow> 
  is_send_path \<E>' (Ch \<pi> xC) \<pi>2 \<Longrightarrow> 
  paths_congruent \<pi>1 path1 \<Longrightarrow>
  paths_congruent \<pi>2 path2 \<Longrightarrow>
  path1 \<asymp> path2
"
using is_send_path_implies_nonempty_pool static_paths_of_same_run_inclusive by fastforce


lemma send_static_paths_equal_exclusive_implies_dynamic_paths_equal: "
pathSync = pathSynca \<or> (\<not> pathSynca \<asymp> pathSync) \<Longrightarrow> 

([[] \<mapsto> \<langle>e;Map.empty;[]\<rangle>], {}) \<rightarrow>* (\<E>', H') \<Longrightarrow>
is_send_path \<E>' (Ch \<pi> xC) \<pi>\<^sub>1 \<Longrightarrow>
is_send_path \<E>' (Ch \<pi> xC) \<pi>\<^sub>2 \<Longrightarrow>

paths_congruent \<pi>\<^sub>1 pathSync \<Longrightarrow>
paths_congruent \<pi>\<^sub>2 pathSynca \<Longrightarrow>

\<pi>\<^sub>1 = \<pi>\<^sub>2
"
by (simp add: equality_preserved_under_congruent send_static_paths_of_same_run_inclusive)

(* END *)


(* PATH SOUND *)

inductive 
  simple_flow_set_env :: "abstract_value_env \<Rightarrow> flow_set \<Rightarrow> val_env \<Rightarrow> bool"  and
  simple_flow_set_val :: "abstract_value_env \<Rightarrow> flow_set \<Rightarrow> val \<Rightarrow> bool"
where
  Intro: "
    \<forall> x \<omega> . \<rho> x = Some \<omega> \<longrightarrow> {|\<omega>|} \<subseteq> \<V> x \<and> simple_flow_set_val V F \<omega> \<Longrightarrow>
    simple_flow_set_env V F \<rho>
  " |

  Unit: "
    simple_flow_set_val V F VUnit
  " |

  Chan: "
    simple_flow_set_val V F (VChan c)
  " |

  Send_Evt: "
    simple_flow_set_env V F \<rho> \<Longrightarrow>
    simple_flow_set_val V F (VClosure (Send_Evt _ _) \<rho>)
  " |

  Recv_Evt: "
    simple_flow_set_env V F \<rho> \<Longrightarrow>
    simple_flow_set_val V F (VClosure (Recv_Evt _) \<rho>)
  " |

  Left: "
    simple_flow_set_env V F \<rho> \<Longrightarrow>
    simple_flow_set_val V F (VClosure (Left _) \<rho>)
  " |

  Right: "
    simple_flow_set_env V F \<rho> \<Longrightarrow>
    simple_flow_set_val V F (VClosure (Right _) \<rho>)
  " |

  Abs: "
    simple_flow_set V F e \<Longrightarrow> 
    simple_flow_set_env V F  \<rho> \<Longrightarrow>
    simple_flow_set_val V F (VClosure (Abs f x e) \<rho>)
  " |

  Pair: "
    simple_flow_set_env V F \<rho> \<Longrightarrow>
    simple_flow_set_val V F (VClosure (Pair _ _) \<rho>)
  " 

inductive simple_flow_set_stack :: "abstract_value_env \<Rightarrow> flow_set \<Rightarrow> cont list \<Rightarrow> bool" where
  Empty: "simple_flow_set_stack V F []" |
  Nonempty: "
    \<lbrakk> 
      simple_flow_set V F e;
      simple_flow_set_env V F \<rho>;
      simple_flow_set_stack V F \<kappa>
    \<rbrakk> \<Longrightarrow> 
    simple_flow_set_stack V F (\<langle>x, e, \<rho>\<rangle> # \<kappa>)
  "


inductive simple_flow_set_pool :: "abstract_value_env \<Rightarrow> flow_set \<Rightarrow> trace_pool \<Rightarrow> bool"  where
  Intro: "
    (\<forall> \<pi> e \<rho> \<kappa> . E \<pi> = Some (\<langle>e;\<rho>;\<kappa>\<rangle>) \<longrightarrow> 
      simple_flow_set V F e \<and>
      simple_flow_set_env V F \<rho> \<and>
      simple_flow_set_stack V F \<kappa>
      ) \<Longrightarrow> 
    simple_flow_set_pool V F E
  "


lemma simple_flow_set_pool_preserved_star: "
  simple_flow_set_pool V F ([[] \<mapsto> \<langle>e;Map.empty;[]\<rangle>]) \<Longrightarrow>
  (V, C) \<Turnstile>\<^sub>e e \<Longrightarrow>
  \<E>' \<pi> = Some (\<langle>LET x = b in e\<^sub>n;\<rho>;\<kappa>\<rangle>) \<Longrightarrow>
  ([[] \<mapsto> \<langle>e;Map.empty;[]\<rangle>], {}) \<rightarrow>* (\<E>', H') \<Longrightarrow>
  isEnd (NLet x) \<Longrightarrow>
  simple_flow_set_pool V F \<E>'
"
sorry

lemma simple_flow_set_pool_implies_may_be_path: "
  \<E>' \<pi> = Some (\<langle>LET x = b in e\<^sub>n;\<rho>;\<kappa>\<rangle>) \<Longrightarrow>
  ([[] \<mapsto> \<langle>e;Map.empty;[]\<rangle>], {}) \<rightarrow>* (\<E>', H') \<Longrightarrow> 
  (V, C) \<Turnstile>\<^sub>e e \<Longrightarrow>
  simple_flow_set_pool V F \<E>' \<Longrightarrow>
  isEnd (NLet x) \<Longrightarrow>
  \<exists> path . 
    paths_congruent \<pi> path \<and>
    may_be_path V F (nodeLabel e) isEnd path
"
sorry


lemma lift_simple_flow_set_to_pool: "
  simple_flow_set V F e \<Longrightarrow>
  simple_flow_set_pool V F [[] \<mapsto> \<langle>e;Map.empty;[]\<rangle>]
"
apply (erule simple_flow_set.cases; auto)
  apply (simp add: simple_flow_set.Result simple_flow_set_env.simps simple_flow_set_pool.Intro simple_flow_set_stack.Empty)
  apply (simp add: simple_flow_set.Let_Unit simple_flow_set_env.simps simple_flow_set_pool.intros simple_flow_set_stack.Empty)
  apply (simp add: simple_flow_set.Let_Chan simple_flow_set_env.simps simple_flow_set_pool.intros simple_flow_set_stack.Empty)
  apply (simp add: simple_flow_set.Let_Send_Evt simple_flow_set_env.simps simple_flow_set_pool.intros simple_flow_set_stack.Empty)
  apply (simp add: simple_flow_set.Let_Recv_Evt simple_flow_set_env.simps simple_flow_set_pool.intros simple_flow_set_stack.Empty)
  apply (simp add: simple_flow_set.Let_Pair simple_flow_set_env.simps simple_flow_set_pool.intros simple_flow_set_stack.Empty)
  apply (simp add: simple_flow_set.Let_Left simple_flow_set_env.simps simple_flow_set_pool.intros simple_flow_set_stack.Empty)
  apply (simp add: simple_flow_set.Let_Right simple_flow_set_env.simps simple_flow_set_pool.intros simple_flow_set_stack.Empty)
  apply (simp add: simple_flow_set.Let_Abs simple_flow_set_env.simps simple_flow_set_pool.intros simple_flow_set_stack.Empty)
  apply (simp add: simple_flow_set.Let_Spawn simple_flow_set_env.simps simple_flow_set_pool.intros simple_flow_set_stack.Empty)
  apply (simp add: simple_flow_set.Let_Sync simple_flow_set_env.simps simple_flow_set_pool.intros simple_flow_set_stack.Empty)
  apply (simp add: simple_flow_set.Let_Fst simple_flow_set_env.simps simple_flow_set_pool.intros simple_flow_set_stack.Empty)
  apply (simp add: simple_flow_set.Let_Snd simple_flow_set_env.simps simple_flow_set_pool.intros simple_flow_set_stack.Empty)
  apply (simp add: simple_flow_set.Let_Case simple_flow_set_env.simps simple_flow_set_pool.intros simple_flow_set_stack.Empty)
  apply (simp add: simple_flow_set.Let_App simple_flow_set_env.simps simple_flow_set_pool.intros simple_flow_set_stack.Empty)
done

lemma isnt_path_sound: "
  \<E>' \<pi> = Some (\<langle>LET x = b in e\<^sub>n;\<rho>;\<kappa>\<rangle>) \<Longrightarrow>
  ([[] \<mapsto> \<langle>e;Map.empty;[]\<rangle>], {}) \<rightarrow>* (\<E>', H') \<Longrightarrow> 
  (V, C) \<Turnstile>\<^sub>e e \<Longrightarrow>
  simple_flow_set V F e \<Longrightarrow>
  isEnd (NLet x) \<Longrightarrow>
  \<exists> path . 
    paths_congruent \<pi> path \<and>
    may_be_path V F (nodeLabel e) isEnd path
"
by (metis lift_simple_flow_set_to_pool simple_flow_set_pool_implies_may_be_path simple_flow_set_pool_preserved_star)


lemma isnt_send_evt_sound: "
  \<lbrakk>
    \<rho>\<^sub>y x\<^sub>e = Some (VClosure (Send_Evt x\<^sub>s\<^sub>c x\<^sub>m) \<rho>\<^sub>e);
    ([[] \<mapsto> \<langle>e;Map.empty;[]\<rangle>], {}) \<rightarrow>* (\<E>', H');
    \<E>' \<pi>\<^sub>y = Some (\<langle>LET x\<^sub>y = SYNC x\<^sub>e in e\<^sub>y;\<rho>\<^sub>y;\<kappa>\<^sub>y\<rangle>);
    (V, C) \<Turnstile>\<^sub>e e
  \<rbrakk> \<Longrightarrow>
  {^Send_Evt x\<^sub>s\<^sub>c x\<^sub>m} \<subseteq> V x\<^sub>e
"
  apply (drule values_not_bound_sound; assumption?; auto)
done

lemma isnt_send_chan_sound: "
  \<lbrakk>
    \<rho>\<^sub>e x\<^sub>s\<^sub>c = Some (VChan (Ch \<pi> xC));
    \<rho>\<^sub>y x\<^sub>e = Some (VClosure (Send_Evt x\<^sub>s\<^sub>c x\<^sub>m) \<rho>\<^sub>e);
    \<E>' \<pi>\<^sub>y = Some (\<langle>LET x\<^sub>y = SYNC x\<^sub>e in e\<^sub>y;\<rho>\<^sub>y;\<kappa>\<^sub>y\<rangle>);
    ([[] \<mapsto> \<langle>e;Map.empty;[]\<rangle>], {}) \<rightarrow>* (\<E>', H');
    (V, C) \<Turnstile>\<^sub>e e
  \<rbrakk> \<Longrightarrow> 
  ^Chan xC \<in> V x\<^sub>s\<^sub>c
"
 apply (frule may_be_static_eval_to_pool)
 apply (drule may_be_static_eval_preserved_under_concur_step_star[of _ _ _ ]; assumption?)
 apply (erule may_be_static_eval_pool.cases; auto)
 apply (drule spec[of _ \<pi>\<^sub>y], drule spec[of _ "\<langle>LET x\<^sub>y = SYNC x\<^sub>e in e\<^sub>y;\<rho>\<^sub>y;\<kappa>\<^sub>y\<rangle>"], simp)
 apply (erule may_be_static_eval_state.cases; auto)
 apply (erule may_be_static_eval_env.cases; auto)
 apply (drule spec[of _ x\<^sub>e], drule spec[of _ "(VClosure (Send_Evt x\<^sub>s\<^sub>c x\<^sub>m) \<rho>\<^sub>e)"]; simp)
 apply (erule conjE)
 apply (erule may_be_static_eval_value.cases; auto)
 apply (erule may_be_static_eval_env.cases; auto)
 apply (drule spec[of _ x\<^sub>s\<^sub>c], drule spec[of _ "(VChan (Ch \<pi> xC))"]; simp)
done

lemma isnt_send_site_sound: "
  \<E>' \<pi>Sync = Some (\<langle>LET x\<^sub>y = SYNC x\<^sub>e in e\<^sub>n;\<rho>;\<kappa>\<rangle>) \<Longrightarrow>
  \<rho> x\<^sub>e = Some (VClosure (Send_Evt x\<^sub>s\<^sub>c x\<^sub>m) \<rho>\<^sub>e) \<Longrightarrow>
  \<rho>\<^sub>e x\<^sub>s\<^sub>c = Some (VChan (Ch \<pi>C xC)) \<Longrightarrow>
  ([[] \<mapsto> \<langle>e;Map.empty;[]\<rangle>], {}) \<rightarrow>* (\<E>', H') \<Longrightarrow> 
  (V, C) \<Turnstile>\<^sub>e e \<Longrightarrow>
  may_be_static_send_node_label V e xC (NLet x\<^sub>y)
"
 apply (unfold may_be_static_send_node_label.simps; auto)
 apply (rule exI[of _ x\<^sub>s\<^sub>c]; auto)
 apply (auto simp: isnt_send_chan_sound)
 apply (rule exI[of _ x\<^sub>m]; auto?)
 apply (rule exI[of _ x\<^sub>e]; auto?)
 apply (blast dest: isnt_send_evt_sound)
 apply (rule exI; auto?)
 apply (erule isnt_exp_sound; auto)
done


lemma isnt_send_path_sound: "
  is_send_path \<E>' (Ch \<pi>C xC) \<pi>Sync \<Longrightarrow>
  ([[] \<mapsto> \<langle>e;Map.empty;[]\<rangle>], {}) \<rightarrow>* (\<E>', H') \<Longrightarrow> 
  (V, C) \<Turnstile>\<^sub>e e \<Longrightarrow>
  simple_flow_set V F e \<Longrightarrow>
  \<exists> pathSync .
    (paths_congruent \<pi>Sync pathSync) \<and> 
    may_be_path V F (nodeLabel e) (may_be_static_send_node_label V e xC) pathSync
"
 apply (unfold is_send_path.simps; auto)
 apply (frule_tac x\<^sub>s\<^sub>c = x\<^sub>s\<^sub>c and \<pi>C = \<pi>C and \<rho>\<^sub>e = \<rho>\<^sub>e in isnt_send_site_sound; auto?)
 apply (frule isnt_path_sound; auto?)
done

(* END PATH SOUND *)



theorem one_shot_sound': "
  every_two_static_paths (may_be_path V F (nodeLabel e) (may_be_static_send_node_label V e xC)) singular \<Longrightarrow>
  simple_flow_set V F e \<Longrightarrow>
  (V, C) \<Turnstile>\<^sub>e e \<Longrightarrow>
  ([[] \<mapsto> \<langle>e;Map.empty;[]\<rangle>], {}) \<rightarrow>* (\<E>', H') \<Longrightarrow>
  every_two_dynamic_paths (is_send_path \<E>' (Ch \<pi> xC)) op =
"
 apply (simp add: every_two_dynamic_paths.simps every_two_static_paths.simps singular.simps; auto)

 apply (frule_tac \<pi>Sync = \<pi>\<^sub>1 in isnt_send_path_sound; auto)
 apply (drule_tac x = pathSync in spec)
 apply (frule_tac \<pi>Sync = \<pi>\<^sub>2 in isnt_send_path_sound; auto?)
 apply (drule_tac x = pathSynca in spec)
 apply (erule impE, simp)
 apply (simp add: equality_preserved_under_congruent send_static_paths_of_same_run_inclusive)
done

theorem one_shot_sound: "
  \<lbrakk>
    static_one_shot V e xC;
    (V, C) \<Turnstile>\<^sub>e e;
    ([[] \<mapsto> \<langle>e;Map.empty;[]\<rangle>], {}) \<rightarrow>* (\<E>', H')
  \<rbrakk> \<Longrightarrow>
  one_shot \<E>' (Ch \<pi> xC)
"
 apply (erule static_one_shot.cases; auto)
 apply (unfold one_shot.simps)
 apply (simp add: one_shot_sound')
done


theorem noncompetitive_send_to_ordered_send: "
  every_two_static_paths (may_be_path V F (nodeLabel e) (may_be_static_send_node_label V e xC)) noncompetitive \<Longrightarrow>
  simple_flow_set V F e \<Longrightarrow>
  (V, C) \<Turnstile>\<^sub>e e \<Longrightarrow>
  ([[] \<mapsto> \<langle>e;Map.empty;[]\<rangle>], {}) \<rightarrow>* (\<E>', H') \<Longrightarrow>
  every_two_dynamic_paths (is_send_path \<E>' (Ch \<pi> xC)) ordered
"
apply (simp add: every_two_static_paths.simps noncompetitive.simps; auto?)
using isnt_send_path_sound static_paths_of_same_run_inclusive sorry


theorem fan_out_sound: "
  \<lbrakk>
    static_fan_out V e xC;
    (V, C) \<Turnstile>\<^sub>e e;
    ([[] \<mapsto> \<langle>e;Map.empty;[]\<rangle>], {}) \<rightarrow>* (\<E>', H')
  \<rbrakk> \<Longrightarrow>
  fan_out \<E>' (Ch \<pi> xC)
"
 apply (erule static_fan_out.cases; auto)
 apply (unfold fan_out.simps)
 apply (metis noncompetitive_send_to_ordered_send)
done

lemma noncompetitive_recv_to_ordered_recv: "
   every_two_static_paths (may_be_path V F (nodeLabel e) (may_be_static_recv_node_label V e xC)) noncompetitive \<Longrightarrow>
   simple_flow_set V F e \<Longrightarrow>
   (V, C) \<Turnstile>\<^sub>e e \<Longrightarrow>
   ([[] \<mapsto> \<langle>e;Map.empty;[]\<rangle>], {}) \<rightarrow>* (\<E>', H') \<Longrightarrow>
   every_two_dynamic_paths (is_recv_path \<E>' (Ch \<pi> xC)) ordered
"
sorry


theorem fan_in_sound: "
  \<lbrakk>
    static_fan_in V e xC;
    (V, C) \<Turnstile>\<^sub>e e;
    ([[] \<mapsto> \<langle>e;Map.empty;[]\<rangle>], {}) \<rightarrow>* (\<E>', H')
  \<rbrakk> \<Longrightarrow>
  fan_in \<E>' (Ch \<pi> xC)
"
 apply (erule static_fan_in.cases; auto)
 apply (unfold fan_in.simps)
 apply (metis noncompetitive_recv_to_ordered_recv)
done


theorem one_to_one_sound: "
  \<lbrakk>
    static_one_to_one V e xC;
    (V, C) \<Turnstile>\<^sub>e e;
    ([[] \<mapsto> \<langle>e;Map.empty;[]\<rangle>], {}) \<rightarrow>* (\<E>', H')
  \<rbrakk> \<Longrightarrow>
  one_to_one \<E>' (Ch \<pi> xC)
"
 apply (erule static_one_to_one.cases; auto)
 apply (unfold one_to_one.simps)
 apply (simp add: noncompetitive_recv_to_ordered_recv noncompetitive_send_to_ordered_send)
done

end
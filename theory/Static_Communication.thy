theory Static_Communication
  imports Main Syntax 
    Dynamic_Semantics Static_Semantics
    Dynamic_Communication
begin

locale communication_sound =
  fixes 
    static_one_shot :: "abstract_env \<Rightarrow> exp \<Rightarrow> var \<Rightarrow> bool" and
    static_fan_out :: "abstract_env \<Rightarrow> exp \<Rightarrow> var \<Rightarrow> bool" and 
    static_fan_in :: "abstract_env \<Rightarrow> exp \<Rightarrow> var \<Rightarrow> bool" and
    static_one_to_one :: "abstract_env \<Rightarrow> exp \<Rightarrow> var \<Rightarrow> bool"

  assumes 
    static_one_shot_sound: "
      static_one_shot V e xC \<Longrightarrow>
      (V, C) \<Turnstile>\<^sub>e e \<Longrightarrow>
      star concur_step ([[] \<mapsto> \<langle>e;Map.empty;[]\<rangle>], {}) (\<E>', H') \<Longrightarrow>
      one_shot \<E>' (Ch \<pi> xC)" and

    static_fan_out_sound: "
      static_fan_out V e xC \<Longrightarrow>
      (V, C) \<Turnstile>\<^sub>e e \<Longrightarrow>
      star concur_step ([[] \<mapsto> \<langle>e;Map.empty;[]\<rangle>], {}) (\<E>', H') \<Longrightarrow>
      fan_out \<E>' (Ch \<pi> xC)" and

    static_fan_in_sound: "
      static_fan_in V e xC \<Longrightarrow>
      (V, C) \<Turnstile>\<^sub>e e \<Longrightarrow>
      star concur_step ([[] \<mapsto> \<langle>e;Map.empty;[]\<rangle>], {}) (\<E>', H') \<Longrightarrow>
      fan_in \<E>' (Ch \<pi> xC)" and

    static_one_to_one_sound: "
      static_one_to_one V e xC \<Longrightarrow>
      (V, C) \<Turnstile>\<^sub>e e \<Longrightarrow>
      star concur_step ([[] \<mapsto> \<langle>e;Map.empty;[]\<rangle>], {}) (\<E>', H') \<Longrightarrow>
      one_to_one \<E>' (Ch \<pi> xC)"


datatype node_label = NLet var | NResult var

fun top_node_label :: "exp \<Rightarrow> node_label" where
  "top_node_label (Let x b e) = NLet x" |
  "top_node_label (Rslt y) = NResult y"

type_synonym node_set = "node_label set"

type_synonym node_map = "node_label \<Rightarrow> var set"

inductive static_send_node_label :: "abstract_env \<Rightarrow> exp \<Rightarrow> var \<Rightarrow> node_label \<Rightarrow> bool" where
  intro: "
    {^Chan xC} \<subseteq> V xSC \<Longrightarrow>
    {^SendEvt xSC xM} \<subseteq> V xE \<Longrightarrow>
    static_reachable e (Let x (Sync xE) e') \<Longrightarrow>
    static_send_node_label V e xC (NLet x)
  "

inductive static_recv_node_label :: "abstract_env \<Rightarrow> exp \<Rightarrow> var \<Rightarrow> node_label \<Rightarrow> bool" where
  intro: "
    {^Chan xC} \<subseteq> V xRC \<Longrightarrow>
    {^RecvEvt xRC} \<subseteq> V xE \<Longrightarrow>
    static_reachable e (Let x (Sync xE) e') \<Longrightarrow>
    static_recv_node_label V e xC (NLet x)
  "



lemma path_state_preserved_for_non_leaf: "
(E, H) \<rightarrow> (E', H') \<Longrightarrow>
E' (\<pi> @ [l]) = Some \<sigma> \<Longrightarrow>
\<not> leaf E \<pi> \<Longrightarrow>
E (\<pi> @ [l]) = Some \<sigma>
"
apply (erule concur_step.cases; auto; (erule seq_step.cases; auto)?)
  apply presburger+
  apply (metis append1_eq_conv fun_upd_other)
  apply (metis butlast_snoc fun_upd_apply)
done


lemma spawn_point: "
  (E, H) \<rightarrow> (E', H') \<Longrightarrow>
  leaf E \<pi> \<Longrightarrow>
  E' (\<pi> @ [l1]) = Some \<sigma>1 \<Longrightarrow>
  E' (\<pi> @ [l2]) = Some \<sigma>2 \<Longrightarrow>
  l1 = l2 \<or> 
  (\<exists> x . l1 = (LNxt x) \<and> l2 = (LSpwn x)) \<or>
  (\<exists> x . l1 = (LSpwn x) \<and> l2 = (LNxt x))
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

lemma always_send_evt_not_bound_sound: "
  \<lbrakk>
    \<rho>\<^sub>y x\<^sub>e = Some (VClsr (SendEvt x\<^sub>s\<^sub>c x\<^sub>m) \<rho>\<^sub>e);
    star concur_step ([[] \<mapsto> \<langle>e;Map.empty;[]\<rangle>], {}) (\<E>', H');
    \<E>' \<pi>\<^sub>y = Some (\<langle>Let x\<^sub>y (Sync x\<^sub>e) e\<^sub>y;\<rho>\<^sub>y;\<kappa>\<^sub>y\<rangle>);
    (V, C) \<Turnstile>\<^sub>e e
  \<rbrakk> \<Longrightarrow>
  {^SendEvt x\<^sub>s\<^sub>c x\<^sub>m} \<subseteq> V x\<^sub>e
"
  apply (drule exp_always_not_static_bound_sound; assumption?; auto)
done

lemma always_recv_evt_not_bound_sound: "
  \<lbrakk>
    \<rho>\<^sub>y x\<^sub>e = Some (VClsr (RecvEvt x\<^sub>r\<^sub>c) \<rho>\<^sub>e);
    star concur_step ([[] \<mapsto> \<langle>e;Map.empty;[]\<rangle>], {}) (\<E>', H');
    \<E>' \<pi>\<^sub>y = Some (\<langle>Let x\<^sub>y (Sync x\<^sub>e) e\<^sub>y;\<rho>\<^sub>y;\<kappa>\<^sub>y\<rangle>);
    (V, C) \<Turnstile>\<^sub>e e
  \<rbrakk> \<Longrightarrow>
  {^RecvEvt x\<^sub>r\<^sub>c} \<subseteq> V x\<^sub>e
"
  apply (drule exp_always_not_static_bound_sound; assumption?; auto)
done

lemma always_send_chan_not_bound_sound: "
  \<lbrakk>
    \<rho>\<^sub>e x\<^sub>s\<^sub>c = Some (VChn (Ch \<pi> xC));
    \<rho>\<^sub>y x\<^sub>e = Some (VClsr (SendEvt x\<^sub>s\<^sub>c x\<^sub>m) \<rho>\<^sub>e);
    \<E>' \<pi>\<^sub>y = Some (\<langle>Let x\<^sub>y (Sync x\<^sub>e) e\<^sub>y;\<rho>\<^sub>y;\<kappa>\<^sub>y\<rangle>);
    star concur_step ([[] \<mapsto> \<langle>e;Map.empty;[]\<rangle>], {}) (\<E>', H');
    (V, C) \<Turnstile>\<^sub>e e
  \<rbrakk> \<Longrightarrow> 
  ^Chan xC \<in> V x\<^sub>s\<^sub>c
"
 apply (frule static_eval_to_pool)
 apply (drule static_eval_preserved_under_concur_step_star[of _ _ _ ]; assumption?)
 apply (erule static_eval_pool.cases; auto)
 apply (drule spec[of _ \<pi>\<^sub>y], drule spec[of _ "\<langle>Let x\<^sub>y (Sync x\<^sub>e) e\<^sub>y;\<rho>\<^sub>y;\<kappa>\<^sub>y\<rangle>"], simp)
 apply (erule static_eval_state.cases; auto)
 apply (erule static_eval_env.cases; auto)
 apply (drule spec[of _ x\<^sub>e], drule spec[of _ "(VClsr (SendEvt x\<^sub>s\<^sub>c x\<^sub>m) \<rho>\<^sub>e)"]; simp)
 apply (erule conjE)
 apply (erule static_eval_value.cases; auto)
 apply (erule static_eval_env.cases; auto)
 apply (drule spec[of _ x\<^sub>s\<^sub>c], drule spec[of _ "(VChn (Ch \<pi> xC))"]; simp)
done

lemma always_recv_chan_not_bound_sound: "
  \<lbrakk>
    \<rho>\<^sub>e x\<^sub>r\<^sub>c = Some (VChn (Ch \<pi> xC));
    \<rho>\<^sub>y x\<^sub>e = Some (VClsr (RecvEvt x\<^sub>r\<^sub>c) \<rho>\<^sub>e);
    \<E>' \<pi>\<^sub>y = Some (\<langle>Let x\<^sub>y (Sync x\<^sub>e) e\<^sub>y;\<rho>\<^sub>y;\<kappa>\<^sub>y\<rangle>);
    star concur_step ([[] \<mapsto> \<langle>e;Map.empty;[]\<rangle>], {}) (\<E>', H');
    (V, C) \<Turnstile>\<^sub>e e
  \<rbrakk> \<Longrightarrow> 
  ^Chan xC \<in> V x\<^sub>r\<^sub>c
"
 apply (frule static_eval_to_pool)
 apply (drule static_eval_preserved_under_concur_step_star[of _ _ _ ]; assumption?)
 apply (erule static_eval_pool.cases; auto)
 apply (drule spec[of _ \<pi>\<^sub>y], drule spec[of _ "\<langle>Let x\<^sub>y (Sync x\<^sub>e) e\<^sub>y;\<rho>\<^sub>y;\<kappa>\<^sub>y\<rangle>"], simp)
 apply (erule static_eval_state.cases; auto)
 apply (erule static_eval_env.cases; auto)
 apply (drule spec[of _ x\<^sub>e], drule spec[of _ "(VClsr (RecvEvt x\<^sub>r\<^sub>c) \<rho>\<^sub>e)"]; simp)
 apply (erule conjE)
 apply (erule static_eval_value.cases; auto)
 apply (erule static_eval_env.cases; auto)
 apply (drule spec[of _ x\<^sub>r\<^sub>c], drule spec[of _ "(VChn (Ch \<pi> xC))"]; simp)
done

lemma node_not_send_site_sound: "
  \<E>' \<pi>Sync = Some (\<langle>Let x\<^sub>y (Sync x\<^sub>e) e\<^sub>n;\<rho>;\<kappa>\<rangle>) \<Longrightarrow>
  \<rho> x\<^sub>e = Some (VClsr (SendEvt x\<^sub>s\<^sub>c x\<^sub>m) \<rho>\<^sub>e) \<Longrightarrow>
  \<rho>\<^sub>e x\<^sub>s\<^sub>c = Some (VChn (Ch \<pi>C xC)) \<Longrightarrow>
  star concur_step ([[] \<mapsto> \<langle>e;Map.empty;[]\<rangle>], {}) (\<E>', H') \<Longrightarrow> 
  (V, C) \<Turnstile>\<^sub>e e \<Longrightarrow>
  static_send_node_label V e xC (NLet x\<^sub>y)
"
 apply (unfold static_send_node_label.simps; auto)
 apply (rule exI[of _ x\<^sub>s\<^sub>c]; auto)
 apply (auto simp: always_send_chan_not_bound_sound)
 apply (rule exI[of _ x\<^sub>m]; auto?)
 apply (rule exI[of _ x\<^sub>e]; auto?)
 apply (blast dest: always_send_evt_not_bound_sound)
 apply (rule exI; auto?)
 apply (erule exp_always_exp_not_static_reachable_sound; auto)
done

lemma node_not_recv_site_sound: "
  \<E>' \<pi>Sync = Some (\<langle>Let x\<^sub>y (Sync x\<^sub>e) e\<^sub>n;\<rho>;\<kappa>\<rangle>) \<Longrightarrow>
  \<rho> x\<^sub>e = Some (VClsr (RecvEvt x\<^sub>r\<^sub>c) \<rho>\<^sub>e) \<Longrightarrow>
  \<rho>\<^sub>e x\<^sub>r\<^sub>c = Some (VChn (Ch \<pi>C xC)) \<Longrightarrow>
  star concur_step ([[] \<mapsto> \<langle>e;Map.empty;[]\<rangle>], {}) (\<E>', H') \<Longrightarrow> 
  (V, C) \<Turnstile>\<^sub>e e \<Longrightarrow>
  static_recv_node_label V e xC (NLet x\<^sub>y)
"
 apply (unfold static_recv_node_label.simps; auto)
 apply (rule exI[of _ x\<^sub>r\<^sub>c]; auto)
 apply (auto simp: always_recv_chan_not_bound_sound)
 apply (rule exI[of _ x\<^sub>e]; auto?)
 apply (blast dest: always_recv_evt_not_bound_sound)
 apply (rule exI; auto?)
 apply (erule exp_always_exp_not_static_reachable_sound; auto)
done

end

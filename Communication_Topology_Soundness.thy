theory Communication_Topology_Soundness
  imports 
    Main 
    Syntax Semantics 
    Abstract_Value_Flow_Analysis Abstract_Value_Flow_Soundness
    Communication_Topology_Analysis
begin


lemma xyz: "
  \<lbrakk> 
    (\<V>, \<C>) \<Turnstile>\<^sub>e e;
    [[] \<mapsto> \<langle>e;Map.empty;[]\<rangle>] \<rightarrow>* \<E>'
  \<rbrakk> \<Longrightarrow>
  (\<forall> \<pi> . \<E>' \<pi> = Some (\<langle>e'; \<rho>'; \<kappa>'\<rangle>) \<longrightarrow> \<parallel>\<rho>'\<parallel> \<sqsubseteq> \<V>)
"
 apply (rule allI, rule impI)
 apply (drule flow_sound[of \<V> \<C> e \<E>' _ e' \<rho>' \<kappa>'], auto)
done


lemma topology_one_shot_sound: "
  [[] \<mapsto> \<langle>e;Map.empty;[]\<rangle>] \<rightarrow>* \<E>' \<Longrightarrow> (\<V>, \<C>) \<Turnstile>\<^sub>e e \<Longrightarrow> 
  one_max (abstract_send_paths \<V> x e) \<Longrightarrow> 
  \<E>' \<pi> = Some (\<langle>LET x = CHAN \<lparr>\<rparr> in e';\<rho>';\<kappa>'\<rangle>) \<Longrightarrow> 
  one_shot \<E>' (Ch \<pi> x)
"
 apply (drule xyz, auto)
 apply (simp add: one_shot_def send_paths_def abstract_value_env_precision_def env_to_abstract_value_env_def)
 apply (simp add: one_max_def abstract_send_paths_def control_paths_def abstract_send_sites_def)
sorry

theorem topology_pair_sound : "
  \<lbrakk>
    (x, t) \<TTurnstile> e;
    [[] \<mapsto> \<langle>e; empty; []\<rangle>] \<rightarrow>* \<E>'
  \<rbrakk> \<Longrightarrow>
  \<langle>\<langle>\<E>'; x\<rangle>\<rangle> \<preceq> t
"
 apply (erule topo_pair_accept.cases; auto)
sorry


lemma topology_sound': "
  (x, \<A> x) \<TTurnstile> e \<Longrightarrow> [[] \<mapsto> \<langle>e; Map.empty; []\<rangle>] \<rightarrow>* \<E>' \<Longrightarrow> (\<langle>\<langle>\<E>'\<rangle>\<rangle>) x \<preceq> \<A> x
"
 apply (drule topology_pair_sound, simp)
 apply (unfold state_pool_to_topo_env_def, auto)
done


theorem topology_sound : "
  \<lbrakk>
    \<A> \<bind> e;
    [[] \<mapsto> \<langle>e; empty; []\<rangle>] \<rightarrow>* \<E>'
  \<rbrakk> \<Longrightarrow>
  \<langle>\<langle>\<E>'\<rangle>\<rangle> \<sqsubseteq>\<^sub>t \<A>
"
 apply (unfold topo_accept_def)
 apply (unfold topo_env_precision_def)
 apply (intro allI, drule spec)
 apply (erule topology_sound', auto)
done

end
theory Communication_Topology_Analysis
  imports Main Syntax Semantics Abstract_Value_Flow_Analysis
begin


datatype topo = OneShot | OneToOne | FanOut | FanIn | Any
type_synonym topo_pair = "var \<times> topo"
type_synonym topo_env = "var \<Rightarrow> topo"



definition send_paths :: "state_pool \<Rightarrow> chan \<Rightarrow> control_path set" where
  "send_paths \<E> ch \<equiv> {\<pi> ;; x | \<pi> x x\<^sub>e e \<kappa> \<rho> x\<^sub>c x\<^sub>m \<rho>\<^sub>e. 
    \<E> \<pi> = Some (\<langle>LET x = SYNC x\<^sub>e in e; \<rho>; \<kappa>\<rangle>) \<and>
    \<rho> x\<^sub>e = Some \<lbrace>Send_Evt x\<^sub>c x\<^sub>m, \<rho>\<^sub>e\<rbrace> \<and> 
    \<rho>\<^sub>e x\<^sub>c = Some \<lbrace>ch\<rbrace>
  }"

definition recv_paths :: "state_pool \<Rightarrow> chan \<Rightarrow> control_path set" where
  "recv_paths \<E> ch \<equiv> {\<pi> ;; x | \<pi> x x\<^sub>e e \<kappa> \<rho> x\<^sub>c \<rho>\<^sub>e. 
    \<E> \<pi> = Some (\<langle>LET x = SYNC x\<^sub>e in e; \<rho>; \<kappa>\<rangle>) \<and> 
    \<rho> x\<^sub>e = Some \<lbrace>Recv_Evt x\<^sub>c, \<rho>\<^sub>e\<rbrace> \<and> 
    \<rho>\<^sub>e x\<^sub>c = Some \<lbrace>ch\<rbrace>
  }"

definition single_side :: "(state_pool \<Rightarrow> chan \<Rightarrow> control_path set) \<Rightarrow> state_pool \<Rightarrow> chan \<Rightarrow> bool" where
  "single_side sites_of \<E> c \<equiv> (\<forall> \<pi>\<^sub>1 \<pi>\<^sub>2 .
    \<pi>\<^sub>1 \<in> sites_of \<E> c \<longrightarrow>
    \<pi>\<^sub>2 \<in> sites_of \<E> c \<longrightarrow>
    (prefix \<pi>\<^sub>1 \<pi>\<^sub>2 \<or> prefix \<pi>\<^sub>2 \<pi>\<^sub>1) 
  )"


definition one_max :: "control_path set \<Rightarrow> bool"  where
  "one_max \<T> \<equiv>  (\<nexists> \<pi> . \<pi> \<in> \<T>) \<or> (\<exists>! \<pi> . \<pi> \<in> \<T>)"

definition one_shot :: "state_pool \<Rightarrow> chan \<Rightarrow> bool" where
  "one_shot \<E> c \<equiv> one_max (send_paths \<E> c) \<and> one_max (recv_paths \<E> c)"

definition single_receiver :: "state_pool \<Rightarrow> chan \<Rightarrow> bool" where 
  "single_receiver \<equiv> single_side recv_paths"

definition single_sender :: "state_pool \<Rightarrow> chan \<Rightarrow> bool" where 
  "single_sender \<equiv> single_side send_paths"

definition one_to_one :: "state_pool \<Rightarrow> chan \<Rightarrow> bool" where
  "one_to_one \<E> c \<equiv> single_sender \<E> c \<and> single_receiver \<E> c"
  
definition fan_out :: "state_pool \<Rightarrow> chan \<Rightarrow> bool" where
  "fan_out \<E> c \<equiv> single_sender \<E> c"
  
definition fan_in :: "state_pool \<Rightarrow> chan \<Rightarrow> bool" where
  "fan_in \<E> c \<equiv> single_receiver \<E> c"

definition var_topo :: "(state_pool \<Rightarrow> chan \<Rightarrow> bool) \<Rightarrow> state_pool \<Rightarrow> var \<Rightarrow> bool" where
  "var_topo t \<E> x \<equiv> (\<forall> \<pi> . (\<exists> e' \<rho>' \<kappa>' . \<E> \<pi> = Some (\<langle>LET x = CHAN \<lparr>\<rparr> in e'; \<rho>'; \<kappa>'\<rangle>)) \<longrightarrow> t \<E> (Ch \<pi> x))"

definition var_to_topo :: "state_pool \<Rightarrow> var \<Rightarrow> topo" ("\<langle>\<langle>_ ; _\<rangle>\<rangle>" [0,0]61) where
  "\<langle>\<langle>\<E> ; x\<rangle>\<rangle> \<equiv>
    (if var_topo one_shot \<E> x then OneShot
    else (if var_topo one_to_one \<E> x then OneToOne
    else (if var_topo fan_out \<E> x then FanOut
    else (if var_topo fan_in \<E> x then FanIn
    else Any))))
  "

definition state_pool_to_topo_env :: "state_pool \<Rightarrow> topo_env" ("\<langle>\<langle>_\<rangle>\<rangle>" [0]61) where
  "\<langle>\<langle>\<E>\<rangle>\<rangle> = (\<lambda> x . \<langle>\<langle>\<E> ; x\<rangle>\<rangle>)"

inductive precision_order :: "topo \<Rightarrow> topo \<Rightarrow> bool" (infix "\<preceq>" 55) where  
  Edge1 : "OneShot \<preceq> OneToOne" | 
  Edge2 : "OneToOne \<preceq> FanOut" |
  Edge3 : "OneToOne \<preceq> FanIn" |
  Edge4 : "FanOut \<preceq> Any" |
  Edge5 : "FanIn \<preceq> Any" |
  Refl : "t \<preceq> t" |
  Trans : "\<lbrakk> a \<preceq> b ; b \<preceq> c \<rbrakk> \<Longrightarrow> a \<preceq> c"

definition topo_env_precision :: "topo_env \<Rightarrow> topo_env \<Rightarrow> bool" (infix "\<sqsubseteq>\<^sub>t" 55) where
  "\<A> \<sqsubseteq>\<^sub>t \<A>' \<equiv> (\<forall> x . \<A> x \<preceq> \<A>' x)"



inductive flow_path_in_exp :: "abstract_value_env \<Rightarrow> control_path \<Rightarrow> exp \<Rightarrow> bool" ("_ \<tturnstile> _ \<triangleleft> _" [56, 0, 56] 55) where
  Result: "\<V> \<tturnstile> [Inl x] \<triangleleft> (RESULT x)" |
  Let_Unit: "
    \<V> \<tturnstile> \<pi> \<triangleleft> e \<Longrightarrow> 
    \<V> \<tturnstile> (Inl x # \<pi>) \<triangleleft> (LET x = \<lparr>\<rparr> in e)
  " |
  Let_Prim: "
    \<V> \<tturnstile> \<pi> \<triangleleft> e \<Longrightarrow> 
    \<V> \<tturnstile> (Inl x # \<pi>) \<triangleleft> (LET x = Prim p in e)
  " |
  Let_Case_Left: "
    \<lbrakk>
      \<V> \<tturnstile> \<pi>\<^sub>l \<triangleleft> e\<^sub>l; 
      \<V> \<tturnstile> \<pi> \<triangleleft> e 
    \<rbrakk>\<Longrightarrow> 
    \<V> \<tturnstile> (\<pi>\<^sub>l @ (Inl x # \<pi>)) \<triangleleft> (LET x = CASE _ LEFT x\<^sub>l |> e\<^sub>l RIGHT _ |> _ in e)
  " |
  Let_Case_Right: "
    \<lbrakk>
      \<V> \<tturnstile> \<pi>\<^sub>r \<triangleleft> e\<^sub>r;
      \<V> \<tturnstile> \<pi> \<triangleleft> e
    \<rbrakk> \<Longrightarrow> 
    \<V> \<tturnstile> (\<pi>\<^sub>r @ (Inl x # \<pi>)) \<triangleleft> (LET x = CASE _ LEFT _ |> _ RIGHT x\<^sub>r |> e\<^sub>r in e)
  " |
  Let_Fst: "
    \<V> \<tturnstile> \<pi> \<triangleleft> e \<Longrightarrow> 
    \<V> \<tturnstile> (Inl x # \<pi>) \<triangleleft> (LET x = FST _ in e)
  " |
  Let_Snd: "
    \<V> \<tturnstile> \<pi> \<triangleleft> e \<Longrightarrow> 
    \<V> \<tturnstile> (Inl x # \<pi>) \<triangleleft> (LET x = SND _ in e)
  " |
  Let_App: "
    \<lbrakk>
      {^Abs f' x' e'} \<subseteq> \<V> f;
      (\<V>(x' := \<V> x' \<inter> \<V> x\<^sub>a)) \<tturnstile> \<pi>' \<triangleleft> e';
      \<V> \<tturnstile> \<pi> \<triangleleft> e
    \<rbrakk> \<Longrightarrow> 
    \<V> \<tturnstile> (\<pi>' @ (Inl x # \<pi>)) \<triangleleft> (LET x = APP f x\<^sub>a in e)
  " |
  Let_Sync: "
   \<V> \<tturnstile> \<pi> \<triangleleft> e \<Longrightarrow>
   \<V> \<tturnstile> (Inl x # \<pi>) \<triangleleft> (LET x = SYNC _ in e)
  " |
  Let_Chan: "
    \<V> \<tturnstile> \<pi> \<triangleleft> e \<Longrightarrow>
    \<V> \<tturnstile> (Inl x # \<pi>) \<triangleleft> (LET x = CHAN \<lparr>\<rparr> in e)
  " |
  Let_Spawn_Parent: " 
    \<V> \<tturnstile> \<pi> \<triangleleft> e \<Longrightarrow>
    \<V> \<tturnstile> (Inl x # \<pi>) \<triangleleft> (LET x = SPAWN _ in e)
  " |
  Let_Spawn_Child: " 
    \<V> \<tturnstile> \<pi> \<triangleleft> e\<^sub>c \<Longrightarrow>
    \<V> \<tturnstile> (Inr () # \<pi>) \<triangleleft> (LET x = SPAWN e\<^sub>c in _)
  "

inductive subexp :: "exp \<Rightarrow> exp \<Rightarrow> bool" (infix "\<unlhd>" 55)where
  Refl: "e \<unlhd> e" |
  Step: "e' \<unlhd> e \<Longrightarrow> e' \<unlhd> (LET x = b in e)"


(*can we determine the sync variable point from just the abstract value environments?*)
definition abstract_send_sites :: "(abstract_value_env \<times> abstract_value_env \<times> exp) \<Rightarrow> var \<Rightarrow> var set" where
  "abstract_send_sites \<A> x\<^sub>c \<equiv> case \<A> of (\<V>, \<C>, e) \<Rightarrow> {x | x x\<^sub>s\<^sub>c x\<^sub>e e' x\<^sub>m . 
    (LET x = SYNC x\<^sub>e in e') \<unlhd> e \<and> 
    ^Chan x\<^sub>c \<in> \<V> x\<^sub>s\<^sub>c \<and>
    {^Send_Evt x\<^sub>s\<^sub>c x\<^sub>m} \<subseteq> \<V> x\<^sub>e \<and>
    {^\<lparr>\<rparr>} \<subseteq> \<V> x \<and> \<V> x\<^sub>m \<subseteq> \<C> x\<^sub>c
  }"

definition abstract_recv_sites :: "(abstract_value_env \<times> abstract_value_env \<times> exp) \<Rightarrow> var \<Rightarrow> var set" where
  "abstract_recv_sites \<A> x\<^sub>c \<equiv> case \<A> of (\<V>, \<C>, e) \<Rightarrow> {x | x x\<^sub>r\<^sub>c x\<^sub>e e'. 
    (LET x = SYNC x\<^sub>e in e') \<unlhd> e \<and> 
    ^Chan x\<^sub>c \<in> \<V> x\<^sub>r\<^sub>c \<and>
    {^Recv_Evt x\<^sub>r\<^sub>c} \<subseteq> \<V> x\<^sub>e \<and>
    \<C> x\<^sub>c \<subseteq> \<V> x
  }"

definition control_paths :: "(abstract_value_env \<times> abstract_value_env \<times> exp) \<Rightarrow> var set \<Rightarrow> control_path set" where 
  "control_paths \<A> sites \<equiv> case \<A> of (\<V>, \<C>, e) \<Rightarrow>  {\<pi>;;x | \<pi> x . 
    (x \<in> sites) \<and> \<V> \<tturnstile> (\<pi>;;x) \<triangleleft> e
  }" 

definition abstract_processes :: "(abstract_value_env \<times> abstract_value_env \<times> exp) \<Rightarrow> var set \<Rightarrow> control_path set" where 
  "abstract_processes \<A> sites \<equiv> {\<pi> \<in> control_paths \<A> sites .
    (\<exists> \<pi>' . (\<pi> @ [Inr ()] @ \<pi>') \<in> control_paths \<A> sites) \<or>
    (\<forall> \<pi>' . (\<pi> @ \<pi>') \<notin> control_paths \<A> sites)
  }"

definition abstract_send_paths :: "(abstract_value_env \<times> abstract_value_env \<times> exp) \<Rightarrow> var \<Rightarrow> control_path set" where 
  "abstract_send_paths \<A> x \<equiv> control_paths \<A> (abstract_send_sites \<A> x)"

definition abstract_recv_paths :: "(abstract_value_env \<times> abstract_value_env \<times> exp) \<Rightarrow> var \<Rightarrow> control_path set" where 
  "abstract_recv_paths \<A> x \<equiv> control_paths \<A> (abstract_recv_sites \<A> x)"

definition abstract_send_processes :: "(abstract_value_env \<times> abstract_value_env \<times> exp) \<Rightarrow> var \<Rightarrow> control_path set" where 
  "abstract_send_processes \<A> x \<equiv> abstract_processes \<A> (abstract_send_sites \<A> x)"

definition abstract_recv_processes :: "(abstract_value_env \<times> abstract_value_env \<times> exp) \<Rightarrow> var \<Rightarrow> control_path set" where 
  "abstract_recv_processes \<A> x \<equiv> abstract_processes \<A> (abstract_recv_sites \<A> x)"

definition abstract_one_shot :: "(abstract_value_env \<times> abstract_value_env \<times> exp) \<Rightarrow> var \<Rightarrow> bool" where
  "abstract_one_shot \<A> x \<equiv> one_max (abstract_send_paths \<A> x) \<and> one_max (abstract_recv_paths \<A> x)"

definition abstract_one_to_one :: "(abstract_value_env \<times> abstract_value_env \<times> exp) \<Rightarrow> var \<Rightarrow> bool" where
  "abstract_one_to_one \<A> x \<equiv> one_max (abstract_send_processes \<A> x) \<and> one_max (abstract_recv_processes \<A> x)"

definition abstract_fan_out :: "(abstract_value_env \<times> abstract_value_env \<times> exp) \<Rightarrow> var \<Rightarrow> bool" where
  "abstract_fan_out \<A> x \<equiv> one_max (abstract_send_processes \<A> x)"

definition abstract_fan_in :: "(abstract_value_env \<times> abstract_value_env \<times> exp) \<Rightarrow> var \<Rightarrow> bool" where
  "abstract_fan_in \<A> x \<equiv> one_max (abstract_recv_processes \<A> x)"


inductive topo_pair_accept :: "topo_pair \<Rightarrow> exp \<Rightarrow> bool" (infix "\<TTurnstile>" 55) where
  OneShot: "
    \<lbrakk>
      (\<V>, \<C>) \<Turnstile>\<^sub>e e;
      abstract_one_shot (\<V>, \<C>, e) x
    \<rbrakk> \<Longrightarrow> 
    (x, OneShot) \<TTurnstile> e
  " | 
  OneToOne: "
    \<lbrakk> 
      (\<V>, \<C>) \<Turnstile>\<^sub>e e;
      abstract_one_to_one (\<V>, \<C>, e) x
    \<rbrakk> \<Longrightarrow> 
    (x, OneToOne) \<TTurnstile> e
  " | 

  FanOut: "
    \<lbrakk>
      (\<V>, \<C>) \<Turnstile>\<^sub>e e;
      abstract_fan_out (\<V>, \<C>, e) x
    \<rbrakk> \<Longrightarrow> 
    (x, FanOut) \<TTurnstile> e
  " | 

  FanIn: "
    \<lbrakk>
      (\<V>, \<C>) \<Turnstile>\<^sub>e e;
      abstract_fan_in (\<V>, \<C>, e) x
    \<rbrakk> \<Longrightarrow> 
    (x, FanIn) \<TTurnstile> e
  " | 

  Any: "(x, Any) \<TTurnstile> e"


definition topo_accept :: "topo_env \<Rightarrow> exp \<Rightarrow> bool" (infix "\<bind>" 55) where 
  "\<A> \<bind> e \<equiv> (\<forall> x . (x, \<A> x) \<TTurnstile> e)"


end

theory Communication_Topology_Analysis
  imports Main Syntax Semantics Abstract_Value_Flow_Analysis
begin


datatype topo = OneShot | OneToOne | FanOut | FanIn | Any
type_synonym topo_pair = "var \<times> topo"
type_synonym topo_env = "var \<Rightarrow> topo"

class com_topo =
  fixes abstract_accept :: "abstract_value_env \<times> abstract_value_env \<Rightarrow> 'a \<Rightarrow> bool" (infix "\<Turnstile>" 55)
  fixes exp_accept :: "exp \<Rightarrow> 'a \<Rightarrow> bool"
  fixes path_accept :: "control_path \<Rightarrow> 'a \<Rightarrow> bool"

definition (in com_topo) abstract_send_sites :: "var \<Rightarrow> 'a \<Rightarrow> var set" where
  "abstract_send_sites x\<^sub>c e \<equiv> {x . \<exists> x\<^sub>e e' x\<^sub>m \<V> \<C>. 
    exp_accept (LET x = SYNC x\<^sub>e in e') e \<and> 
    abstract_accept (\<V>, \<C>) e \<and> 
    {^Send_Evt x\<^sub>c x\<^sub>m} \<subseteq> \<V> x\<^sub>e
  }"

definition (in com_topo) abstract_recv_sites :: "var \<Rightarrow> 'a \<Rightarrow> var set" where
  "abstract_recv_sites x\<^sub>c e \<equiv> {x . \<exists> x\<^sub>e e' \<V> \<C>. 
    exp_accept (LET x = SYNC x\<^sub>e in e') e \<and> 
    abstract_accept (\<V>, \<C>) e \<and> 
    {^Recv_Evt x\<^sub>c} \<subseteq> \<V> x\<^sub>e
  }"

definition (in com_topo) control_paths :: "var set \<Rightarrow> 'a \<Rightarrow> control_path set" where 
  "control_paths sites e \<equiv> {\<pi>;;x | \<pi> x . 
    (x \<in> sites) \<and>  path_accept (\<pi>;;x) e
  }" 

definition (in com_topo) abstract_processes :: "var set \<Rightarrow> 'a \<Rightarrow> control_path set" where 
  "abstract_processes sites e \<equiv> {\<pi> \<in> control_paths sites e .
    (\<exists> \<pi>' . (\<pi> @ [Inr ()] @ \<pi>') \<in> control_paths sites e) \<or>
    (\<forall> \<pi>' . (\<pi> @ \<pi>') \<notin> control_paths sites e)
  }" 

definition (in com_topo) abstract_send_paths :: "var \<Rightarrow> 'a \<Rightarrow> control_path set"  where 
  "abstract_send_paths c e \<equiv> control_paths (abstract_send_sites c e) e"

definition (in com_topo) abstract_recv_paths :: "var \<Rightarrow> 'a \<Rightarrow> control_path set"  where 
  "abstract_recv_paths c e \<equiv> control_paths (abstract_recv_sites c e) e"

definition (in com_topo) abstract_send_processes :: "var \<Rightarrow> 'a \<Rightarrow> control_path set"  where 
  "abstract_send_processes c e = abstract_processes (abstract_send_sites c e) e"

definition (in com_topo) abstract_recv_processes :: "var \<Rightarrow> 'a \<Rightarrow> control_path set"  where 
  "abstract_recv_processes c e = abstract_processes (abstract_recv_sites c e) e"

definition one_max :: "control_path set \<Rightarrow> bool"  where
  "one_max \<T> \<equiv>  (\<nexists> p . p \<in> \<T>) \<or> (\<exists>! p . p \<in> \<T>)"


inductive (in com_topo) topo_pair_accept :: "topo_pair \<Rightarrow> 'a \<Rightarrow> bool" (infix "\<TTurnstile>" 55) where
  OneShot: "
    one_max (abstract_send_paths c e) \<Longrightarrow> 
    (c, OneShot) \<TTurnstile> e
  " | 
  OneToOne: "
    \<lbrakk> 
      one_max (abstract_send_processes c e) ;
      one_max (abstract_recv_processes c e) 
    \<rbrakk> \<Longrightarrow> 
    (c, OneToOne) \<TTurnstile> e
  " | 

  FanOut: "
    one_max (abstract_send_processes c e) \<Longrightarrow> 
    (c, FanOut) \<TTurnstile> e
  " | 

  FanIn: "
    one_max (abstract_recv_processes c e) \<Longrightarrow> 
    (c, FanIn) \<TTurnstile> e
  " | 

  Any: "(c, Any) \<TTurnstile> e"




(***************)



definition send_sites :: "state_pool \<Rightarrow> chan \<Rightarrow> control_path set" where
  "send_sites \<E> ch = {\<pi>. \<exists> x x\<^sub>e e \<kappa> \<rho> x\<^sub>c x\<^sub>m \<rho>\<^sub>e. 
    \<E> \<pi> = Some (\<langle>LET x = SYNC x\<^sub>e in e; \<rho>; \<kappa>\<rangle>) \<and> 
    \<rho> x\<^sub>e = Some \<lbrace>Send_Evt x\<^sub>c x\<^sub>m, \<rho>\<^sub>e\<rbrace> \<and> 
    \<rho>\<^sub>e x\<^sub>c = Some \<lbrace>ch\<rbrace>
  }"

definition recv_sites :: "state_pool \<Rightarrow> chan \<Rightarrow> control_path set" where
  "recv_sites \<E> ch = {\<pi>. \<exists> x x\<^sub>e e \<kappa> \<rho> x\<^sub>c \<rho>\<^sub>e. 
    \<E> \<pi> = Some (\<langle>LET x = SYNC x\<^sub>e in e; \<rho>; \<kappa>\<rangle>) \<and> 
    \<rho> x\<^sub>e = Some \<lbrace>Recv_Evt x\<^sub>c, \<rho>\<^sub>e\<rbrace> \<and> 
    \<rho>\<^sub>e x\<^sub>c = Some \<lbrace>ch\<rbrace>
  }"

definition single_side :: "(state_pool \<Rightarrow> chan \<Rightarrow> control_path set) \<Rightarrow> state_pool \<Rightarrow> chan \<Rightarrow> bool" where
  "single_side sites_of \<E> c \<longleftrightarrow> (\<forall> \<pi>\<^sub>1 \<pi>\<^sub>2 .
    \<pi>\<^sub>1 \<in> sites_of \<E> c \<longrightarrow>
    \<pi>\<^sub>2 \<in> sites_of \<E> c \<longrightarrow>
    (prefix \<pi>\<^sub>1 \<pi>\<^sub>2 \<or> prefix \<pi>\<^sub>2 \<pi>\<^sub>1) 
  )"

definition one_shot :: "state_pool \<Rightarrow> chan \<Rightarrow> bool" where
  "one_shot \<E> c \<longleftrightarrow> card (send_sites \<E> c) \<le> 1"

definition single_receiver :: "state_pool \<Rightarrow> chan \<Rightarrow> bool" where 
  "single_receiver = single_side recv_sites"

definition single_sender :: "state_pool \<Rightarrow> chan \<Rightarrow> bool" where 
  "single_sender = single_side recv_sites"

definition point_to_point :: "state_pool \<Rightarrow> chan \<Rightarrow> bool" where
  "point_to_point \<E> c \<longleftrightarrow> single_sender \<E> c \<and> single_receiver \<E> c"
  
definition fan_out :: "state_pool \<Rightarrow> chan \<Rightarrow> bool" where
  "fan_out \<E> c \<longleftrightarrow> single_sender \<E> c \<and> \<not> single_receiver \<E> c"
  
definition fan_in :: "state_pool \<Rightarrow> chan \<Rightarrow> bool" where
  "fan_in \<E> c \<longleftrightarrow> \<not> single_sender \<E> c \<and> single_receiver \<E> c"

definition var_topo :: "(state_pool \<Rightarrow> chan \<Rightarrow> bool) \<Rightarrow> state_pool \<Rightarrow> var \<Rightarrow> bool" where
  "var_topo t \<E> x \<longleftrightarrow> (\<forall> \<pi> . \<exists> x' e' \<rho>' \<kappa>' . \<E> \<pi> = Some (\<langle>LET x' = CHAN \<lparr>\<rparr> in e'; \<rho>'; \<kappa>'\<rangle>) \<longrightarrow> t \<E> (Ch \<pi> x))"

definition var_to_topo :: "state_pool \<Rightarrow> var \<Rightarrow> topo" ("\<langle>\<langle>_ ; _\<rangle>\<rangle>" [0,0]61) where
  "\<langle>\<langle>\<E> ; x\<rangle>\<rangle> = 
    (if var_topo one_shot \<E> x then OneShot
    else (if var_topo point_to_point \<E> x then OneToOne
    else (if var_topo fan_out \<E> x then FanOut
    else (if var_topo fan_in \<E> x then FanOut
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


inductive path_in_exp' :: "abstract_value_env \<Rightarrow> control_path \<Rightarrow> exp \<Rightarrow> bool" ("_ \<Turnstile> _ \<triangleleft> _" [56, 0, 56] 55) where
  Result: "\<V> \<Turnstile> [Inl x] \<triangleleft> (RESULT x)" |
  Let_Unit: "
    \<V> \<Turnstile> \<pi> \<triangleleft> e \<Longrightarrow> 
    \<V> \<Turnstile> (Inl x # \<pi>) \<triangleleft> (LET x = \<lparr>\<rparr> in e)
  " |
  Let_Prim: "
    \<V> \<Turnstile> \<pi> \<triangleleft> e \<Longrightarrow> 
    \<V> \<Turnstile> (Inl x # \<pi>) \<triangleleft> (LET x = Prim p in e)
  " |
  Let_Case_Left: "
    \<lbrakk>
      \<V> \<Turnstile> \<pi>\<^sub>l \<triangleleft> e\<^sub>l; 
      \<V> \<Turnstile> \<pi> \<triangleleft> e 
    \<rbrakk>\<Longrightarrow> 
    \<V> \<Turnstile> (\<pi>\<^sub>l @ (Inl x # \<pi>)) \<triangleleft> (LET x = CASE _ LEFT x\<^sub>l |> e\<^sub>l RIGHT _ |> _ in e)
  " |
  Let_Case_Right: "
    \<lbrakk>
      \<V> \<Turnstile> \<pi>\<^sub>r \<triangleleft> e\<^sub>r;
      \<V> \<Turnstile> \<pi> \<triangleleft> e
    \<rbrakk> \<Longrightarrow> 
    \<V> \<Turnstile> (\<pi>\<^sub>r @ (Inl x # \<pi>)) \<triangleleft> (LET x = CASE _ LEFT _ |> _ RIGHT x\<^sub>r |> e\<^sub>r in e)
  " |
  Let_Fst: "
    \<V> \<Turnstile> \<pi> \<triangleleft> e \<Longrightarrow> 
    \<V> \<Turnstile> (Inl x # \<pi>) \<triangleleft> (LET x = FST _ in e)
  " |
  Let_Snd: "
    \<V> \<Turnstile> \<pi> \<triangleleft> e \<Longrightarrow> 
    \<V> \<Turnstile> (Inl x # \<pi>) \<triangleleft> (LET x = SND _ in e)
  " |
  Let_App: "
    \<lbrakk>
      {^Abs f' x' e'} \<subseteq> \<V> f;
      (\<V>(x' := \<V> x' \<inter> \<V> x\<^sub>a)) \<Turnstile> \<pi>' \<triangleleft> e';
      \<V> \<Turnstile> \<pi> \<triangleleft> e
    \<rbrakk> \<Longrightarrow> 
    \<V> \<Turnstile> (\<pi>' @ (Inl x # \<pi>)) \<triangleleft> (LET x = APP f x\<^sub>a in e)
  " |
  Let_Sync: "
   \<V> \<Turnstile> \<pi> \<triangleleft> e \<Longrightarrow>
   \<V> \<Turnstile> (Inl x # \<pi>) \<triangleleft> (LET x = SYNC _ in e)
  " |
  Let_Chan: "
    \<V> \<Turnstile> \<pi> \<triangleleft> e \<Longrightarrow>
    \<V> \<Turnstile> (Inl x # \<pi>) \<triangleleft> (LET x = CHAN \<lparr>\<rparr> in e)
  " |
  Let_Spawn_Parent: " 
    \<V> \<Turnstile> \<pi> \<triangleleft> e \<Longrightarrow>
    \<V> \<Turnstile> (Inl x # \<pi>) \<triangleleft> (LET x = SPAWN _ in e)
  " |
  Let_Spawn_Child: " 
    \<V> \<Turnstile> \<pi> \<triangleleft> e\<^sub>c \<Longrightarrow>
    \<V> \<Turnstile> (Inr () # \<pi>) \<triangleleft> (LET x = SPAWN e\<^sub>c in _)
  " 

definition path_in_exp :: "control_path \<Rightarrow> exp \<Rightarrow> bool" (infix "\<triangleleft>" 55)where
  "\<pi> \<triangleleft> e \<equiv> (\<exists> \<V> \<C> . (\<V>, \<C>) \<Turnstile>\<^sub>e e \<and> (\<V> \<Turnstile> \<pi> \<triangleleft> e))"

inductive subexp :: "exp \<Rightarrow> exp \<Rightarrow> bool" (infix "\<unlhd>" 55)where
  Refl: "e \<unlhd> e" |
  Step: "e' \<unlhd> e \<Longrightarrow> e' \<unlhd> (LET x = b in e)"

instantiation exp :: com_topo
begin
definition abstract_accept_exp where "\<T> \<Turnstile> e \<equiv> \<T> \<Turnstile>\<^sub>e e" 
definition exp_accept_exp where "exp_accept e' e \<equiv> e' \<unlhd> e"
definition path_accept_exp where "path_accept \<pi> e \<equiv> \<pi> \<triangleleft> e"
instance proof qed
end 


definition topo_accept :: "topo_env \<Rightarrow> exp \<Rightarrow> bool" (infix "\<bind>" 55) where 
  "\<A> \<bind> e \<equiv> (\<forall> x . (x, \<A> x) \<TTurnstile> e)"


inductive exp_in_pool :: "exp \<Rightarrow> state_pool \<Rightarrow> bool" (infix "\<lhd>|" 55)where
  Any: "
    \<lbrakk>
      \<E> \<pi> = Some (\<langle>e; \<rho>; \<kappa>\<rangle>);
      e' \<unlhd> e
    \<rbrakk> \<Longrightarrow>
    e' \<lhd>| \<E>
  "

datatype state_pool' = SP state_pool
instantiation state_pool' :: com_topo
begin
fun abstract_accept_state_pool' where "\<T> \<Turnstile> (SP \<E>) = \<T> \<Turnstile>\<^sub>\<E> \<E>" 
fun exp_accept_state_pool' where "exp_accept e' (SP \<E>) = e' \<lhd>| \<E>"
fun path_accept_state_pool' where "path_accept \<pi> (SP \<E>) = \<pi> \<triangleleft> e"
instance proof qed
end 

end

theory Analysis
  imports Main Syntax
begin


(*

determine values of higher-order abstractions and channels
determine program points (Var x) send/receive on a static channel (Var c)
determine which paths reach (Var x)
determine total number of processes and paths that reach every (Var x)


How to represent loops statically?
  stop after first loop is recorded.  Only care if there is either one or more.
*)


datatype abstract_value = Chan var | Unit | Prim prim

type_synonym abstract_value_env = "var \<Rightarrow> abstract_value set"

inductive val_env_accept :: "abstract_value_env \<Rightarrow> exp \<Rightarrow> bool" (infix "\<Turnstile>" 55) where  
  Something: "x \<Turnstile> y" (*TO DO*)


type_synonym abstract_path = "(var + unit) list"

inductive path_sub_accept :: "abstract_value_env \<Rightarrow> abstract_path \<Rightarrow> exp \<Rightarrow> bool" where
  Result: "path_sub_accept \<rho> [Inl x] (RESULT x)" |
  Let_Unit: "
    path_sub_accept \<rho> \<pi> e \<Longrightarrow> 
    path_sub_accept \<rho> ((Inl x) # \<pi>) (LET x = \<lparr>\<rparr> in e)
  " |
  Let_Prim: "
    path_sub_accept \<rho> \<pi> e \<Longrightarrow> 
    path_sub_accept \<rho> ((Inl x) # \<pi>) (LET x = B_Prim p in e)
  " |
  Let_Case_Left: "
    \<lbrakk>
      path_sub_accept \<rho> \<pi>_l e_l; 
      path_sub_accept \<rho> \<pi> e 
    \<rbrakk>\<Longrightarrow> 
    path_sub_accept \<rho> (\<pi>_l @ ((Inl x) # \<pi>)) (LET x = CASE x_sum LEFT x_l |> e_l RIGHT _ |> _ in e)
  " |
  Let_Case_Right: "
    \<lbrakk>
      path_sub_accept \<rho> \<pi>_r e_r;
      path_sub_accept \<rho> \<pi> e
    \<rbrakk> \<Longrightarrow> 
    path_sub_accept \<rho> (\<pi>_r @ ((Inl x) # \<pi>)) (LET x = CASE x_sum LEFT _ |> _ RIGHT x_r |> e_r in e)
  " |
  Let_Fst: "
    path_sub_accept \<rho> \<pi> e \<Longrightarrow> 
    path_sub_accept \<rho> ((Inl x) # \<pi>) (LET x = FST _ in e)
  " |
  Let_Snd: "
    path_sub_accept \<rho> \<pi> e \<Longrightarrow> 
    path_sub_accept \<rho> ((Inl x) # \<pi>) (LET x = SND _ in e)
  " |
  Let_App: "
    \<lbrakk>
      (Prim (P_Abs f' x' e' )) \<in> (\<rho> x_f);
       path_sub_accept (\<rho>(x' := (\<rho> x') \<inter> (\<rho> x_a))) \<pi>' e'
    \<rbrakk>\<Longrightarrow> 
    path_sub_accept \<rho> (\<pi>' @ ((Inl x) # \<pi>)) (LET x = APP x_f x_a in e)
  " |
  Let_Sync: "
   path_sub_accept \<rho> \<pi> e \<Longrightarrow>
   path_sub_accept \<rho> (Inl x # \<pi>) (LET x = SYNC x_evt in e)
  " |
  Let_Chan: "
    path_sub_accept \<rho> \<pi> e \<Longrightarrow>
    path_sub_accept \<rho> (Inl x # \<pi>) (LET x = CHAN \<lparr>\<rparr> in e)
  " |
  Let_Spawn_Parent: " 
    path_sub_accept \<rho> \<pi> e \<Longrightarrow>
    path_sub_accept \<rho> (Inl x # \<pi>) (LET x = SPAWN _ in e)
  " |
  Let_Spawn_Child: " 
    path_sub_accept \<rho> \<pi> e_child \<Longrightarrow>
    path_sub_accept \<rho> (Inr () # \<pi>) (LET x = SPAWN e_child in _)
  " 

definition path_accept :: "abstract_path \<Rightarrow> exp \<Rightarrow> bool" where
  "path_accept \<pi> e \<equiv> (\<exists> \<rho> . \<rho> \<Turnstile> e \<and> path_sub_accept \<rho> \<pi> e)"

definition paths_to :: "var \<Rightarrow> exp \<Rightarrow> abstract_path set" where
  "paths_to x e = {\<pi> @ [Inl x] | \<pi> . path_accept (\<pi> @ [Inl x]) e}"


inductive subexp :: "exp \<Rightarrow> exp \<Rightarrow> bool" where
  Refl: "subexp e e" |
  Step: "subexp e' e \<Longrightarrow> subexp e' (LET _ = _ in e)"

definition send_sites :: "var \<Rightarrow> exp \<Rightarrow> var set" where
  "send_sites c e = {x . \<exists> y e' \<rho> z. 
    subexp (LET x = SYNC y in e') e \<and> 
    val_env_accept \<rho> e \<and> 
    Prim (P_Send_Evt c z) \<in> (\<rho> y)
  }"

definition recv_sites :: "var \<Rightarrow> exp \<Rightarrow> var set" where
  "recv_sites c e = {x . \<exists> y e' \<rho>. 
    subexp (LET x = SYNC y in e') e \<and> 
    val_env_accept \<rho> e \<and> 
    Prim (P_Recv_Evt c) \<in> (\<rho> y)
  }"

definition paths :: "var set \<Rightarrow> var \<Rightarrow> exp \<Rightarrow> abstract_path set" where 
  "paths sites c e = {path @ [Inl x] | path x . 
    (x \<in> sites) \<and>  (path @ [Inl x] \<in> paths_to x e)
  }" 

definition send_paths where 
  "send_paths c e = paths (send_sites c e) c e"

definition recv_paths where 
  "recv_paths c e = paths (recv_sites c e) c e"

definition path_count :: "abstract_path set \<Rightarrow> nat"  where
  "path_count s = card s" (*TO DO*)

definition process_count :: "abstract_path set \<Rightarrow> nat"  where
  "process_count s = card s"(*TO DO*)


datatype topo_class = OneShot | OneToOne | FanOut | FanIn | Any

type_synonym topo_class_pair = "var \<times> topo_class"

inductive class_pair_accept :: "topo_class_pair \<Rightarrow> exp \<Rightarrow> bool" where
  OneShot: "
    path_count (send_paths c e) \<le> 1 \<Longrightarrow> 
    class_pair_accept (c, OneShot) e
  " | 

  OneToOne: "
    \<lbrakk> 
      process_count (send_paths c e) \<le> 1 ;
      process_count (receive_paths c e) \<le> 1 
    \<rbrakk> \<Longrightarrow> 
    class_pair_accept (c, OneToOne) e
  " | 

  FanOut: "
    \<lbrakk> 
      process_count (send_paths c e) \<le> 1
    \<rbrakk> \<Longrightarrow> 
    class_pair_accept (c, FanOut) e
  " | 

  FanIn: "
    process_count (receive_paths c e) \<le> 1 \<Longrightarrow> 
    class_pair_accept (c, OneToOne) e
  " | 

  Any: "class_pair_accept (c, OneToOne) e"


type_synonym topo_class_env = "var \<Rightarrow> topo_class"

definition test :: "bool \<Rightarrow> bool" where
  Something:  "test b \<equiv> b"

definition class_env_accept :: "topo_class_env \<Rightarrow> exp \<Rightarrow> bool" where 
  "class_env_accept E e \<equiv> (\<forall> (x::var) (t::topo_class) . ((E x) = t) \<and> (class_pair_accept (x, t) e))"



inductive precision_order :: "topo_class \<Rightarrow> topo_class \<Rightarrow> bool" (infix "\<preceq>" 55) where  
  Edge1 : "OneShot \<preceq> OneToOne" | 
  Edge2 : "OneToOne \<preceq> FanOut" |
  Edge3 : "OneToOne \<preceq> FanIn" |
  Edge4 : "FanOut \<preceq> Any" |
  Edge5 : "FanIn \<preceq> Any" |
  Refl : "t \<preceq> t" |
  Trans : "\<lbrakk> a \<preceq> b ; b \<preceq> c \<rbrakk> \<Longrightarrow> a \<preceq> c"

end
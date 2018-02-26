theory Communication_Analysis
  imports Main Syntax Semantics Abstract_Value_Flow_Analysis
begin

definition send_paths :: "state_pool \<Rightarrow> chan \<Rightarrow> control_path set" where
  "send_paths \<E> c \<equiv> {\<pi>\<^sub>y ;; `x\<^sub>y | \<pi>\<^sub>y x\<^sub>y x\<^sub>e e\<^sub>n \<kappa> \<rho> x\<^sub>s\<^sub>c x\<^sub>m \<rho>\<^sub>e. 
    \<E> \<pi>\<^sub>y = Some (\<langle>LET x\<^sub>y = SYNC x\<^sub>e in e\<^sub>n; \<rho>; \<kappa>\<rangle>) \<and>
    \<rho> x\<^sub>e = Some \<lbrace>Send_Evt x\<^sub>s\<^sub>c x\<^sub>m, \<rho>\<^sub>e\<rbrace> \<and> 
    \<rho>\<^sub>e x\<^sub>s\<^sub>c = Some \<lbrace>c\<rbrace> \<and>
    \<E> (\<pi>\<^sub>y;;`x\<^sub>y) = Some (\<langle>e\<^sub>n; \<rho>(x\<^sub>y \<mapsto> \<lbrace>\<rbrace>); \<kappa>\<rangle>)
  }"

definition recv_paths :: "state_pool \<Rightarrow> chan \<Rightarrow> control_path set" where
  "recv_paths \<E> c \<equiv> {\<pi>\<^sub>y ;; `x\<^sub>y | \<pi>\<^sub>y x\<^sub>y x\<^sub>e e\<^sub>n \<kappa> \<rho> x\<^sub>r\<^sub>c \<rho>\<^sub>e \<omega>. 
    \<E> \<pi>\<^sub>y = Some (\<langle>LET x\<^sub>y = SYNC x\<^sub>e in e\<^sub>n; \<rho>; \<kappa>\<rangle>) \<and> 
    \<rho> x\<^sub>e = Some \<lbrace>Recv_Evt x\<^sub>r\<^sub>c, \<rho>\<^sub>e\<rbrace> \<and> 
    \<rho>\<^sub>e x\<^sub>r\<^sub>c = Some \<lbrace>c\<rbrace> \<and>
    \<E> (\<pi>\<^sub>y;;`x\<^sub>y) = Some (\<langle>e\<^sub>n; \<rho>(x\<^sub>y \<mapsto> \<omega>); \<kappa>\<rangle>)
  }"


inductive same_proc :: "control_path \<Rightarrow> control_path \<Rightarrow> bool" (infix "\<cong>" 55) where
  Lin: "
    \<lbrakk>
      ``\<pi>\<^sub>1``; ``\<pi>\<^sub>2``
    \<rbrakk> \<Longrightarrow>
    \<pi>\<^sub>1 \<cong> \<pi>\<^sub>2
  " |
  Cons: "
    \<lbrakk>
      \<pi>\<^sub>1 \<cong> \<pi>\<^sub>2
    \<rbrakk> \<Longrightarrow>
    l # \<pi>\<^sub>1 \<cong> l # \<pi>\<^sub>2 
  "

theorem same_proc_preserved_under_concat: "
  \<pi>\<^sub>1' \<cong> \<pi>\<^sub>2' \<Longrightarrow> \<pi> @ \<pi>\<^sub>1' \<cong> \<pi> @ \<pi>\<^sub>2'
"
 apply (induct \<pi>, simp)
 apply (simp add: same_proc.Cons)
done

theorem same_proc_commutative[simp]: "
  \<pi>\<^sub>1 \<cong> \<pi>\<^sub>2 \<Longrightarrow> \<pi>\<^sub>2 \<cong> \<pi>\<^sub>1
"
 apply (erule same_proc.induct)
  apply (simp add: Lin)
 apply (simp add: same_proc.Cons)
done

fun proc_spawn' :: "control_path \<Rightarrow> (control_label list) \<Rightarrow> control_path" where
  "proc_spawn' [] r = rev r" |
  "proc_spawn' (.x # \<pi>) r = proc_spawn' \<pi> []" |
  "proc_spawn' (l # \<pi>) r = proc_spawn' \<pi> (l # r)"

fun proc_spawn :: "control_path \<Rightarrow> control_path" where
  "proc_spawn \<pi> = proc_spawn' \<pi> []"

fun proc_legacy' where 
  "proc_legacy' [] = []" |
  "proc_legacy' (.x # xs) = (.x # xs)" |
  "proc_legacy' (_ # xs) = proc_legacy' xs"

fun proc_legacy :: "control_path \<Rightarrow> control_path" where
  "proc_legacy \<pi> = rev (proc_legacy' (rev \<pi>))"


definition two_paths_ordered :: "control_path \<Rightarrow> control_path \<Rightarrow> bool" where "two_paths_ordered \<pi>\<^sub>1 \<pi>\<^sub>2  = (prefix \<pi>\<^sub>1 \<pi>\<^sub>2 \<or> prefix \<pi>\<^sub>2 \<pi>\<^sub>1)"

definition two_paths_exclusive :: "control_path \<Rightarrow> control_path \<Rightarrow> bool" where 
 "two_paths_exclusive \<pi>\<^sub>1 \<pi>\<^sub>2 = (\<pi>\<^sub>1 = \<pi>\<^sub>2 \<or> (\<pi>\<^sub>1 \<cong> \<pi>\<^sub>2 \<and> \<not>(two_paths_ordered (proc_spawn \<pi>\<^sub>1) (proc_spawn \<pi>\<^sub>2))))"

definition two_paths_noncompetitive :: "control_path \<Rightarrow> control_path \<Rightarrow> bool" where
  "two_paths_noncompetitive \<pi>\<^sub>1 \<pi>\<^sub>2 = (\<pi>\<^sub>1 \<cong> \<pi>\<^sub>2 \<or> two_paths_ordered \<pi>\<^sub>1 \<pi>\<^sub>2 \<or> two_paths_exclusive (proc_legacy \<pi>\<^sub>1) (proc_legacy \<pi>\<^sub>2))"

definition set_noncompetitive  :: "control_path set \<Rightarrow> bool" where
  "set_noncompetitive \<T> \<equiv> (\<forall> \<pi>\<^sub>1 \<pi>\<^sub>2 .
    \<pi>\<^sub>1 \<in> \<T> \<longrightarrow>
    \<pi>\<^sub>2 \<in> \<T> \<longrightarrow>
    two_paths_noncompetitive \<pi>\<^sub>1 \<pi>\<^sub>2
  )"

definition set_exclusive :: "control_path set \<Rightarrow> bool"  where
  "set_exclusive \<T> \<equiv> (\<forall> \<pi>\<^sub>1 \<pi>\<^sub>2 . 
    \<pi>\<^sub>1 \<in> \<T> \<longrightarrow> 
    \<pi>\<^sub>2 \<in> \<T> \<longrightarrow>
    two_paths_exclusive \<pi>\<^sub>1 \<pi>\<^sub>2
  )"


definition one_shot :: "state_pool \<Rightarrow> chan \<Rightarrow> bool" where
  "one_shot \<E> c \<equiv> set_exclusive (send_paths \<E> c) \<and> set_exclusive (recv_paths \<E> c)"


definition one_to_one :: "state_pool \<Rightarrow> chan \<Rightarrow> bool" where
  "one_to_one \<E> c \<equiv> set_noncompetitive (send_paths \<E> c) \<and> set_noncompetitive (recv_paths \<E> c)"
  
definition fan_out :: "state_pool \<Rightarrow> chan \<Rightarrow> bool" where
  "fan_out \<E> c \<equiv> set_noncompetitive (send_paths \<E> c)"
  
definition fan_in :: "state_pool \<Rightarrow> chan \<Rightarrow> bool" where
  "fan_in \<E> c \<equiv> set_noncompetitive (recv_paths \<E> c)"


end
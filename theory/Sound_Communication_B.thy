theory Sound_Communication_B
  imports Main Syntax 
    Dynamic_Semantics Static_Semantics Sound_Semantics
    Dynamic_Communication Static_Communication Sound_Communication
    Static_Communication_B
begin


inductive 
  staticFlowsAcceptEnv :: "static_env \<Rightarrow> flow_set \<Rightarrow> env \<Rightarrow> bool"  and
  staticFlowsAcceptVal :: "static_env \<Rightarrow> flow_set \<Rightarrow> val \<Rightarrow> bool"
where
  StaticFlowsAcceptEnv:
  "
    \<forall> x \<omega> . \<rho> x = Some \<omega> \<longrightarrow>  staticFlowsAcceptVal V F \<omega> \<Longrightarrow>
    staticFlowsAcceptEnv V F \<rho>
  "
| Unit:
  "
    staticFlowsAcceptVal V F VUnt
  "
| Chan:
  "
    staticFlowsAcceptVal V F (VChn c)
  "
| SendEvt:
  "
    staticFlowsAcceptEnv V F \<rho> \<Longrightarrow>
    staticFlowsAcceptVal V F (VClsr (SendEvt _ _) \<rho>)
  "
| RecvEvt:
  "
    staticFlowsAcceptEnv V F \<rho> \<Longrightarrow>
    staticFlowsAcceptVal V F (VClsr (RecvEvt _) \<rho>)
  "
| Left:
  "
    staticFlowsAcceptEnv V F \<rho> \<Longrightarrow>
    staticFlowsAcceptVal V F (VClsr (Lft _) \<rho>)
  "
| Right:
  "
    staticFlowsAcceptEnv V F \<rho> \<Longrightarrow>
    staticFlowsAcceptVal V F (VClsr (Rht _) \<rho>)
  "
| Fun:
  "
    staticFlowsAccept V F e \<Longrightarrow> 
    staticFlowsAcceptEnv V F  \<rho> \<Longrightarrow>
    staticFlowsAcceptVal V F (VClsr (Fun f x e) \<rho>)
  "
| Pair:
  "
    staticFlowsAcceptEnv V F \<rho> \<Longrightarrow>
    staticFlowsAcceptVal V F (VClsr (Pair _ _) \<rho>)
  " 


inductive staticFlowsAcceptStack :: "static_env \<Rightarrow> flow_set \<Rightarrow> name \<Rightarrow> contin list \<Rightarrow> bool" where
  Empty: "staticFlowsAcceptStack V F y []"
| Nonempty:
  "
    \<lbrakk> 
      {(IdRslt y, EReturn, tmId e)} \<subseteq> F;
      staticFlowsAccept V F e;
      staticFlowsAcceptEnv V F \<rho>;
      staticFlowsAcceptStack V F (\<lfloor>e\<rfloor>) \<kappa>
    \<rbrakk> \<Longrightarrow> 
    staticFlowsAcceptStack V F y ((Ctn x e \<rho>) # \<kappa>)
  "

inductive staticFlowsAcceptPool :: "static_env \<Rightarrow> flow_set \<Rightarrow> trace_pool \<Rightarrow> bool"  where
  Intro:
  "
    (\<forall> \<pi> e \<rho> \<kappa> . E \<pi> = Some (Stt e \<rho> \<kappa>) \<longrightarrow> 
      staticFlowsAccept V F e \<and>
      staticFlowsAcceptEnv V F \<rho> \<and>
      staticFlowsAcceptStack V F (\<lfloor>e\<rfloor>) \<kappa>) \<Longrightarrow> 
    staticFlowsAcceptPool V F E
  "

inductive 
  staticLiveChanEnv :: "static_env \<Rightarrow> tm_id_map \<Rightarrow> tm_id_map \<Rightarrow> name \<Rightarrow> env \<Rightarrow> bool"  and
  staticLiveChanVal :: "static_env \<Rightarrow> tm_id_map \<Rightarrow> tm_id_map \<Rightarrow> name \<Rightarrow> val \<Rightarrow> bool"
where
  StaticLiveChanEnv:
  "
    \<forall> x \<omega> . \<rho> x = Some \<omega> \<longrightarrow>  staticLiveChanVal V Ln Lx x\<^sub>c \<omega> \<Longrightarrow>
    staticLiveChanEnv V Ln Lx x\<^sub>c \<rho>
  "
| StaticLiveChanUnit:
  "
    staticLiveChanVal V Ln Lx x\<^sub>c VUnt
  "
| StaticLiveChan:
  "
    staticLiveChanVal V Ln Lx x\<^sub>c (VChn c)
  "
| StaticLiveChanSendEvt:
  "
    staticLiveChanEnv V Ln Lx x\<^sub>c \<rho> \<Longrightarrow>
    staticLiveChanVal V Ln Lx x\<^sub>c (VClsr (SendEvt _ _) \<rho>)
  "
| StaticLiveChanRecvEvt:
  "
    staticLiveChanEnv V Ln Lx x\<^sub>c \<rho> \<Longrightarrow>
    staticLiveChanVal V Ln Lx x\<^sub>c (VClsr (RecvEvt _) \<rho>)
  "
| StaticLiveChanLeft:
  "
    staticLiveChanEnv V Ln Lx x\<^sub>c \<rho> \<Longrightarrow>
    staticLiveChanVal V Ln Lx x\<^sub>c (VClsr (Lft _) \<rho>)
  "
| StaticLiveChanRight:
  "
    staticLiveChanEnv V Ln Lx x\<^sub>c \<rho> \<Longrightarrow>
    staticLiveChanVal V Ln Lx x\<^sub>c (VClsr (Rht _) \<rho>)
  "
| StaticLiveChanFun:
  "
    staticLiveChan V Ln Lx x\<^sub>c e \<Longrightarrow> 
    staticLiveChanEnv V Ln Lx x\<^sub>c \<rho> \<Longrightarrow>
    staticLiveChanVal V Ln Lx x\<^sub>c (VClsr (Fun f x e) \<rho>)
  "
| StaticLiveChanPair:
  "
    staticLiveChanEnv V Ln Lx x\<^sub>c \<rho> \<Longrightarrow>
    staticLiveChanVal V Ln Lx x\<^sub>c (VClsr (Pair _ _) \<rho>)
  " 


inductive staticLiveChanStack :: "static_env \<Rightarrow> tm_id_map \<Rightarrow> tm_id_map \<Rightarrow> name \<Rightarrow> contin list \<Rightarrow> bool" where
  Empty: "staticLiveChanStack V Ln Lx x\<^sub>c []"
| Nonempty:
  "
    \<lbrakk> 
      (* \<not> Set.is_empty (Ln (tmId e)); *)
      staticLiveChan V Ln Lx x\<^sub>c e;
      staticLiveChanEnv V Ln Lx x\<^sub>c \<rho>; 
      staticLiveChanStack V Ln Lx x\<^sub>c \<kappa>
    \<rbrakk> \<Longrightarrow> 
    staticLiveChanStack V Ln Lx x\<^sub>c ((Ctn x e \<rho>) # \<kappa>)
  "


inductive staticLiveChanPool ::  "static_env \<Rightarrow> tm_id_map \<Rightarrow> tm_id_map \<Rightarrow> name \<Rightarrow> trace_pool \<Rightarrow> bool"  where
  Intro:
  "
    (\<forall> \<pi> e \<rho> \<kappa> . pool \<pi> = Some (Stt e \<rho> \<kappa>) \<longrightarrow>
      staticLiveChan V Ln Lx x\<^sub>c e \<and>
      staticLiveChanEnv V Ln Lx x\<^sub>c \<rho> \<and>
      staticLiveChanStack V Ln Lx x\<^sub>c \<kappa>) \<Longrightarrow>
    staticLiveChanPool V Ln Lx x\<^sub>c pool
  "

lemma staticInclusive_commut: "
  staticInclusive path\<^sub>1 path\<^sub>2 \<Longrightarrow> staticInclusive path\<^sub>2 path\<^sub>1
"
 apply (erule staticInclusive.cases; auto)
  apply (simp add: Prefix2)
  apply (simp add: Prefix1)
  apply (simp add: Spawn2)
  apply (simp add: Spawn1)
  apply (simp add: Send2)
  apply (simp add: Send1)
done


lemma staticInclusivePreservedDynamicEval_under_unordered_extension: "
  \<not> prefix path\<^sub>1 path\<^sub>2 \<Longrightarrow> 
  \<not> prefix path\<^sub>2 path\<^sub>1 \<Longrightarrow> 
  staticInclusive path\<^sub>1 path\<^sub>2 \<Longrightarrow> 
  staticInclusive (path\<^sub>1 @ [l]) path\<^sub>2
"
 apply (erule staticInclusive.cases; auto)
  apply (simp add: Spawn1)
  apply (simp add: Spawn2)
  apply (simp add: Send1)
  apply (simp add: Send2)
done

lemma staticInclusivePreservedDynamicEval_under_unordered_double_extension: "
  staticInclusive path\<^sub>1 path\<^sub>2 \<Longrightarrow> 
  \<not> prefix path\<^sub>1 path\<^sub>2 \<Longrightarrow> 
  \<not> prefix path\<^sub>2 path\<^sub>1 \<Longrightarrow> 
  staticInclusive (path\<^sub>1 @ [l1]) (path\<^sub>2 @ [l2])
"
by (metis staticInclusive_commut staticInclusivePreservedDynamicEval_under_unordered_extension prefix_append prefix_def)


inductive pathsCongruent :: "control_path \<Rightarrow> static_path \<Rightarrow> bool" where
  Empty:
  "
    pathsCongruent [] []
  "
| Next:
  "
    pathsCongruent \<pi> path \<Longrightarrow>
    pathsCongruent (\<pi> @ [LNxt x]) (path @ [(IdBind x, ENext)])
  "
| Spawn:
  "
    pathsCongruent \<pi> path \<Longrightarrow>
    pathsCongruent (\<pi> @ [LSpwn x]) (path @ [(IdBind x, ESpawn)])
  "
| Call:
  "
    pathsCongruent \<pi> path \<Longrightarrow>
    pathsCongruent (\<pi> @ [LCall x]) (path @ [(IdBind x, ECall)])
  "  
| Return:
  "
    pathsCongruent \<pi> path \<Longrightarrow>
    pathsCongruent (\<pi> @ [LRtn y]) (path @ [(IdRslt y, EReturn)])
  " 


inductive pathsCongruentModChan :: 
  "trace_pool * communication \<Rightarrow> chan \<Rightarrow> control_path \<Rightarrow> static_path \<Rightarrow> bool" 
where
  Empty: "pathsCongruentModChan (\<E>, H) c [] []"
| Chan:
  "
    pathsCongruent ((LNxt xC) # \<pi>Suff) path \<Longrightarrow>
    \<E> (\<pi>C @ (LNxt xC) # \<pi>Suff) \<noteq> None \<Longrightarrow>
    pathsCongruentModChan (\<E>, H) (Ch \<pi>C xC) (\<pi>C @ (LNxt xC) # \<pi>Suff) path
  " 
| Sync:
(*  inducts on the strict prefix up to channel passing point*) 
  "
    pathsCongruent \<pi>Suffix pathSuffix \<Longrightarrow>
    \<E> (\<pi>R @ (LNxt xR) # \<pi>Suffix) \<noteq> None \<Longrightarrow>
    dynamicBuiltOnChan \<rho>RY c xR \<Longrightarrow>
    \<E> \<pi>S = Some (Stt (Bind xS (Sync xSE) eSY) \<rho>SY \<kappa>SY) \<Longrightarrow>
    \<E> \<pi>R = Some (Stt (Bind xR (Sync xRE) eRY) \<rho>RY \<kappa>RY) \<Longrightarrow>
    {(\<pi>S, c_c, \<pi>R)} \<subseteq> H \<Longrightarrow> 
    pathsCongruentModChan (\<E>, H) c \<pi>S pathPre \<Longrightarrow>
    pathsCongruentModChan (\<E>, H) c (\<pi>R @ (LNxt xR) # \<pi>Suffix) (pathPre @ (IdBind xS, ESend xSE) # (IdBind xR, ENext) # pathSuffix)
  " 


lemma staticInclusiveSound: "
  star dynamicEval ([[] \<mapsto> (Stt e empty [])], {}) (\<E>', H') \<Longrightarrow> 
  staticLiveChan V Ln Lx xC e \<Longrightarrow>
  staticFlowsAccept V F e \<Longrightarrow>
  (V, C) \<Turnstile>\<^sub>e e \<Longrightarrow>

  \<E>' \<pi>1 \<noteq> None \<Longrightarrow> 
  pathsCongruentModChan (\<E>', H') (Ch \<pi> xC) \<pi>1 path1 \<Longrightarrow>
  staticTraceable F Ln Lx (IdBind xC) (staticSendSite V e xC) path1 \<Longrightarrow>
  
  \<E>' \<pi>2 \<noteq> None \<Longrightarrow> 
  pathsCongruentModChan (\<E>', H') (Ch \<pi> xC) \<pi>2 path2 \<Longrightarrow>
  staticTraceable F Ln Lx (IdBind xC) (staticSendSite V e xC) path2 \<Longrightarrow>

  staticInclusive path1 path2
"
sorry

lemma is_send_path_implies_nonempty_pool: "
  is_send_path \<E> (Ch \<pi>C xC) \<pi> \<Longrightarrow> 
  \<E> \<pi> \<noteq> None
"
proof -
  assume H1: "is_send_path \<E> (Ch \<pi>C xC) \<pi>"
  
  then have
    H2:
  "
      \<exists> x\<^sub>y x\<^sub>e e\<^sub>n \<rho> \<kappa>. \<E> \<pi> = Some (Stt (Bind x\<^sub>y (Sync x\<^sub>e) e\<^sub>n) \<rho> \<kappa>) 
    " using is_send_path.simps by auto

  then show 
    "\<E> \<pi> \<noteq> None" by blast
qed


lemma static_equalitySound: "
  path1 = path2 \<Longrightarrow>

  star dynamicEval ([[] \<mapsto> (Stt e empty [])], {}) (\<E>', H') \<Longrightarrow> 
  staticLiveChan V Ln Lx xC e \<Longrightarrow>
  staticFlowsAccept V F e \<Longrightarrow>
  (V, C) \<Turnstile>\<^sub>e e \<Longrightarrow>
  
  \<E>' \<pi>1 \<noteq> None \<Longrightarrow> 
  pathsCongruentModChan (\<E>', H') (Ch \<pi> xC) \<pi>1 path1 \<Longrightarrow>
  staticTraceable F Ln Lx (IdBind xC) (staticSendSite V e xC) path1 \<Longrightarrow>
  
  pathsCongruentModChan (\<E>', H') (Ch \<pi> xC) \<pi>2 path2 \<Longrightarrow>
  staticTraceable F Ln Lx (IdBind xC) (staticSendSite V e xC) path2 \<Longrightarrow>
  \<E>' \<pi>2 \<noteq> None \<Longrightarrow> 

  \<pi>1 = \<pi>2
"
  sorry

(* PATH SOUND *)

lemma staticFlowsAcceptPoolPreservedReturn: 
"
  staticFlowsAcceptPool V F Em \<Longrightarrow>
  (V, C) \<Turnstile>\<^sub>e e0 \<Longrightarrow>
  star_left dynamicEval ([[] \<mapsto> Stt e0 Map.empty []], {}) (Em, Hm) \<Longrightarrow>
  staticFlowsAcceptPool V F [[] \<mapsto> Stt e0 Map.empty []] \<Longrightarrow>
  leaf Em pi \<Longrightarrow>
  Em pi = Some (Stt (Rslt x) env (Ctn xk ek envk # k)) \<Longrightarrow>
  env x = Some v \<Longrightarrow>
  staticFlowsAcceptPool V F (Em(pi @ [LRtn x] \<mapsto> Stt ek (envk(xk \<mapsto> v)) k))
"
apply (rule staticFlowsAcceptPool.Intro; auto)

  apply (erule staticFlowsAcceptPool.cases; auto)
  apply (drule spec[of _ pi]; auto)
  apply (erule staticFlowsAcceptStack.cases; auto)

  apply (erule staticFlowsAcceptPool.cases; auto)
  apply (drule spec[of _ pi]; auto)
  apply (erule staticFlowsAcceptEnv.cases; auto)
  apply (drule spec[of _ x]; auto)
  apply (erule staticFlowsAcceptStack.cases; auto)
  apply (simp add: staticFlowsAcceptEnv.simps)

  apply (erule staticFlowsAcceptPool.cases; auto)
  apply (drule spec[of _ pi]; auto)
  apply (erule staticFlowsAcceptStack.cases; auto)

  apply (erule staticFlowsAcceptPool.cases; auto)+
done

lemma staticFlowsAcceptPoolPreservedSeqEval:
"
staticFlowsAcceptPool V F Em \<Longrightarrow>
(V, C) \<Turnstile>\<^sub>e e0 \<Longrightarrow>
star_left op \<rightarrow> ([[] \<mapsto> Stt e0 Map.empty []], {}) (Em, Hm) \<Longrightarrow>
staticFlowsAcceptPool V F [[] \<mapsto> Stt e0 Map.empty []] \<Longrightarrow>
leaf Em pi \<Longrightarrow>
Em pi = Some (Stt (Bind x b e) env k) \<Longrightarrow>
seqEval b env v \<Longrightarrow>
staticFlowsAcceptPool V F (Em(pi @ [LNxt x] \<mapsto> Stt e (env(x \<mapsto> v)) k))
"
apply (rule staticFlowsAcceptPool.Intro; auto)

  apply (erule staticFlowsAcceptPool.cases; auto)
  apply (drule spec[of _ pi]; auto)
  apply (erule staticFlowsAccept.cases; auto)

  apply (frule staticFlowsAcceptPool.cases; auto)
  apply (drule spec[of _ pi]; auto)
  apply (erule seqEval.cases; auto)

    apply (simp add: staticFlowsAcceptEnv.simps staticFlowsAcceptEnv_staticFlowsAcceptVal.Unit)

    apply (erule staticFlowsAccept.cases; auto)

      apply (erule staticFlowsAcceptPool.cases; auto)
      apply (drule spec[of _ pi]; auto)
      apply (rotate_tac -2)
      apply (erule staticFlowsAccept.cases; auto)
      apply (smt map_upd_Some_unfold staticFlowsAcceptEnv.cases StaticFlowsAcceptEnv staticFlowsAcceptEnv_staticFlowsAcceptVal.SendEvt)
      
      apply (erule staticFlowsAcceptPool.cases; auto)
      apply (drule spec[of _ pi]; auto)
      apply (rotate_tac -2)
      apply (erule staticFlowsAccept.cases; auto)
      apply (smt map_upd_Some_unfold staticFlowsAcceptEnv.cases StaticFlowsAcceptEnv staticFlowsAcceptEnv_staticFlowsAcceptVal.RecvEvt)

      apply (erule staticFlowsAcceptPool.cases; auto)
      apply (drule spec[of _ pi]; auto)
      apply (rotate_tac -2)
      apply (erule staticFlowsAccept.cases; auto)
      apply (smt map_upd_Some_unfold staticFlowsAcceptEnv.cases StaticFlowsAcceptEnv staticFlowsAcceptEnv_staticFlowsAcceptVal.Pair)

      apply (erule staticFlowsAcceptPool.cases; auto)
      apply (drule spec[of _ pi]; auto)
      apply (rotate_tac -2)
      apply (erule staticFlowsAccept.cases; auto)
      apply (smt map_upd_Some_unfold staticFlowsAcceptEnv.cases StaticFlowsAcceptEnv staticFlowsAcceptEnv_staticFlowsAcceptVal.Left)

      apply (erule staticFlowsAcceptPool.cases; auto)
      apply (drule spec[of _ pi]; auto)
      apply (rotate_tac -2)
      apply (erule staticFlowsAccept.cases; auto)
      apply (smt map_upd_Some_unfold staticFlowsAcceptEnv.cases StaticFlowsAcceptEnv staticFlowsAcceptEnv_staticFlowsAcceptVal.Right)

      apply (erule staticFlowsAcceptPool.cases; auto)
      apply (drule spec[of _ pi]; auto)
      apply (rotate_tac -2)
      apply (erule staticFlowsAccept.cases; auto)
      apply (smt map_upd_Some_unfold staticFlowsAcceptEnv.cases staticFlowsAcceptEnv_staticFlowsAcceptVal.Fun StaticFlowsAcceptEnv)


   apply (frule staticFlowsAcceptPool.cases; auto)
   apply (drule spec[of _pi]; auto)
   apply (erule staticFlowsAcceptEnv.cases; auto)
   apply (drule_tac x = "xp" in spec; auto)
   apply (erule staticFlowsAcceptVal.cases; auto)
   apply (rename_tac xp envp x1 x2)
   apply (erule staticFlowsAcceptEnv.cases; auto)
   apply (drule_tac x = "x1" in spec; auto)
   apply (erule staticFlowsAcceptPool.cases; auto)
   apply (drule spec[of _pi]; auto)
   apply (simp add: staticFlowsAcceptEnv.simps)

   apply (frule staticFlowsAcceptPool.cases; auto)
   apply (drule spec[of _pi]; auto)
   apply (erule staticFlowsAcceptEnv.cases; auto)
   apply (drule_tac x = "xp" in spec; auto)
   apply (erule staticFlowsAcceptVal.cases; auto)
   apply (rename_tac xp envp x1 x2)
   apply (erule staticFlowsAcceptEnv.cases; auto)
   apply (drule_tac x = "x2" in spec; auto)
   apply (erule staticFlowsAcceptPool.cases; auto)
   apply (drule spec[of _pi]; auto)
   apply (simp add: staticFlowsAcceptEnv.simps)

 apply (erule staticFlowsAcceptPool.cases; auto)
 apply (drule spec[of _pi]; auto)

 apply (erule staticFlowsAcceptPool.cases; auto)+

done

lemma staticFlowsAcceptPoolPreservedCallEval:
"
staticFlowsAcceptPool V F Em \<Longrightarrow>
(V, C) \<Turnstile>\<^sub>e e0 \<Longrightarrow>
star_left op \<rightarrow> ([[] \<mapsto> Stt e0 Map.empty []], {}) (Em, Hm) \<Longrightarrow>
staticFlowsAcceptPool V F [[] \<mapsto> Stt e0 Map.empty []] \<Longrightarrow>
leaf Em pi \<Longrightarrow>
Em pi = Some (Stt (Bind x b e) env k) \<Longrightarrow>
callEval (b, env) (e', env') \<Longrightarrow>
staticFlowsAcceptPool V F (Em(pi @ [LCall x] \<mapsto> Stt e' env' (Ctn x e env # k)))
"
apply (rule staticFlowsAcceptPool.Intro; auto)

  apply (erule staticFlowsAcceptPool.cases; auto)
  apply (drule spec[of _ pi]; auto)
  apply (erule callEval.cases; auto)
    apply (erule staticFlowsAccept.cases; auto)
    apply (erule staticFlowsAccept.cases; auto)
    apply (erule staticFlowsAcceptEnv.cases; auto)
    apply (drule_tac x = "f" in spec; auto)
    apply (erule staticFlowsAcceptVal.cases; auto)
  apply (erule callEval.cases; auto)
    apply (erule staticFlowsAcceptPool.cases; auto)
    apply (drule spec[of _ pi]; auto)
    apply (frule staticFlowsAcceptEnv.cases; auto)
    apply (drule_tac x = "xs" in spec; auto)
    apply (erule staticFlowsAcceptVal.cases; auto)
    apply (rename_tac xs vl xl xr er envl xl')
    apply (rotate_tac -1)
    apply (erule staticFlowsAcceptEnv.cases; auto)
    apply (rename_tac xs vl xl xr er xl' envl)
    apply (drule_tac x = "xl'" in spec; auto)
    apply (simp add: staticFlowsAcceptEnv.simps)

    apply (erule staticFlowsAcceptPool.cases; auto)
    apply (drule spec[of _ pi]; auto)
    apply (frule staticFlowsAcceptEnv.cases; auto)
    apply (drule_tac x = "xs" in spec; auto)
    apply (erule staticFlowsAcceptVal.cases; auto)
    apply (rename_tac xs vl xl xr er envr xr')
    apply (rotate_tac -1)
    apply (erule staticFlowsAcceptEnv.cases; auto)
    apply (rename_tac xs vl xl xr er xr' envr)
    apply (drule_tac x = "xr'" in spec; auto)
    apply (simp add: staticFlowsAcceptEnv.simps)

    apply (rule StaticFlowsAcceptEnv; auto)
      
      apply (erule staticFlowsAcceptPool.cases; auto)
      apply (drule spec[of _ pi]; auto)
      apply (erule staticFlowsAcceptEnv.cases; auto)

      apply (erule staticFlowsAcceptPool.cases; auto)
      apply (drule spec[of _ pi]; auto)
      apply (erule staticFlowsAcceptEnv.cases; auto)

      apply (erule staticFlowsAcceptPool.cases; auto)
      apply (drule spec[of _ pi]; auto)
      apply (erule staticFlowsAcceptEnv.cases; auto)

      apply (erule staticFlowsAcceptPool.cases; auto)
      apply (drule spec[of _ pi]; auto)
      apply (erule staticFlowsAcceptEnv.cases; auto)
      apply (drule_tac x = "f" in spec; auto)
      apply (erule staticFlowsAcceptVal.cases; auto)
      apply (erule staticFlowsAcceptEnv.cases; auto)

    apply (erule callEval.cases; auto)
      apply (erule staticFlowsAcceptPool.cases; auto)
      apply (drule spec[of _ pi]; auto)
      apply (erule staticFlowsAccept.cases; auto)
      apply (simp add: staticFlowsAcceptStack.Nonempty)

      apply (erule staticFlowsAcceptPool.cases; auto)
      apply (drule spec[of _ pi]; auto)
      apply (erule staticFlowsAccept.cases; auto)
      apply (simp add: staticFlowsAcceptStack.Nonempty)

      apply (erule staticFlowsAcceptPool.cases; auto)
      apply (drule spec[of _ pi]; auto)
      apply (erule staticFlowsAccept.cases; auto)
      apply (drule_tac x = "fp" in spec)
      apply (drule_tac x = "xp" in spec)
      apply (drule spec[of _ e'])
      apply (drule staticEval_to_pool)
      apply (rotate_tac -1)
      apply (drule staticEvalPreserved[of V C _ "{}" Em Hm]; auto)
      apply (simp add: star_left_implies_star)+
        apply (erule notE)
        apply (rotate_tac -1)
        apply (erule staticEvalPool.cases; auto)
        apply (drule spec[of _ pi]; auto)
        apply (erule staticEvalState.cases; auto)
        apply (erule staticEvalEnv.cases; auto)
        apply (drule_tac x = "fa" in spec; auto)
      apply (simp add: staticFlowsAcceptStack.Nonempty)

  apply (erule staticFlowsAcceptPool.cases; auto)+

done

lemma staticFlowsAcceptPoolPreservedMkChan:
"
staticFlowsAcceptPool V F Em \<Longrightarrow>
(V, C) \<Turnstile>\<^sub>e e0 \<Longrightarrow>
star_left op \<rightarrow> ([[] \<mapsto> Stt e0 Map.empty []], {}) (Em, Hm) \<Longrightarrow>
staticFlowsAcceptPool V F [[] \<mapsto> Stt e0 Map.empty []] \<Longrightarrow>
leaf Em pi \<Longrightarrow>
Em pi = Some (Stt (Bind x MkChn e) env k) \<Longrightarrow>
staticFlowsAcceptPool V F (Em(pi @ [LNxt x] \<mapsto> Stt e (env(x \<mapsto> VChn (Ch pi x))) k))
"
apply (rule staticFlowsAcceptPool.Intro; auto)
 
  apply (erule staticFlowsAcceptPool.cases; auto)
  apply (drule spec[of _ pi]; auto)
  apply (erule staticFlowsAccept.cases; auto)

  apply (rule StaticFlowsAcceptEnv; auto)
  apply (simp add: staticFlowsAcceptEnv_staticFlowsAcceptVal.Chan)
  apply (erule staticFlowsAcceptPool.cases; auto)
  apply (drule spec[of _ pi]; auto)
  apply (erule staticFlowsAcceptEnv.cases; auto)

  apply (erule staticFlowsAcceptPool.cases; auto)
  apply (drule spec[of _ pi]; auto)

  apply (erule staticFlowsAcceptPool.cases; auto)+
done
  
lemma staticFlowsAcceptPoolPreservedSpawn:
"
  staticFlowsAcceptPool V F Em \<Longrightarrow>
  (V, C) \<Turnstile>\<^sub>e e0 \<Longrightarrow>
  star_left op \<rightarrow> ([[] \<mapsto> Stt e0 Map.empty []], {}) (Em, Hm) \<Longrightarrow>
  staticFlowsAcceptPool V F [[] \<mapsto> Stt e0 Map.empty []] \<Longrightarrow>
  leaf Em pi \<Longrightarrow>
  Em pi = Some (Stt (Bind x (Spwn ec) e) env k) \<Longrightarrow>
  staticFlowsAcceptPool V F (Em(pi @ [LNxt x] \<mapsto> Stt e (env(x \<mapsto> VUnt)) k, pi @ [LSpwn x] \<mapsto> Stt ec env []))
"
apply (rule staticFlowsAcceptPool.Intro; auto)

  apply (erule staticFlowsAcceptPool.cases; auto)
  apply (drule spec[of _ pi]; auto)
  apply (erule staticFlowsAccept.cases; auto)

  apply (rule StaticFlowsAcceptEnv; auto)
  using staticFlowsAcceptEnv_staticFlowsAcceptVal.Unit apply blast
  apply (erule staticFlowsAcceptPool.cases; auto)
  apply (drule spec[of _ pi]; auto)
  apply (erule staticFlowsAcceptEnv.cases; auto)

  apply (erule staticFlowsAcceptPool.cases; auto)
  apply (drule spec[of _ pi]; auto)

  apply (erule notE)
  apply (erule staticFlowsAcceptPool.cases; auto)
  apply (drule spec[of _ pi]; auto)
  apply (erule staticFlowsAccept.cases; auto)

  apply (erule staticFlowsAcceptPool.cases; auto)

  using staticFlowsAcceptStack.Empty apply blast

  apply (erule staticFlowsAcceptPool.cases; auto)+
done

lemma staticFlowsAcceptPoolPreservedSync:
"
  staticFlowsAcceptPool V F Em \<Longrightarrow>
  (V, C) \<Turnstile>\<^sub>e e0 \<Longrightarrow>
  star_left op \<rightarrow> ([[] \<mapsto> Stt e0 Map.empty []], {}) (Em, Hm) \<Longrightarrow>
  staticFlowsAcceptPool V F [[] \<mapsto> Stt e0 Map.empty []] \<Longrightarrow>
  leaf Em pis \<Longrightarrow>
  Em pis = Some (Stt (Bind xs (Sync xse) es) envs ks) \<Longrightarrow>
  envs xse = Some (VClsr (SendEvt xsc xm) envse) \<Longrightarrow>
  leaf Em pir \<Longrightarrow>
  Em pir = Some (Stt (Bind xr (Sync xre) er) envr kr) \<Longrightarrow>
  envr xre = Some (VClsr (RecvEvt xrc) envre) \<Longrightarrow>
  envse xsc = Some (VChn c) \<Longrightarrow>
  envre xrc = Some (VChn c) \<Longrightarrow>
  envse xm = Some vm \<Longrightarrow>
  staticFlowsAcceptPool V F (Em(pis @ [LNxt xs] \<mapsto> Stt es (envs(xs \<mapsto> VUnt)) ks, pir @ [LNxt xr] \<mapsto> Stt er (envr(xr \<mapsto> vm)) kr))
"
apply (rule staticFlowsAcceptPool.Intro; auto)

  apply (erule staticFlowsAcceptPool.cases; auto)
  apply (drule spec[of _ pis]; auto)
  apply (erule staticFlowsAccept.cases; auto)

  apply (rule StaticFlowsAcceptEnv; auto)
  using staticFlowsAcceptEnv_staticFlowsAcceptVal.Unit apply blast
  apply (erule staticFlowsAcceptPool.cases; auto)
  apply (drule spec[of _ pis]; auto)
  apply (erule staticFlowsAcceptEnv.cases; auto)

  apply (erule staticFlowsAcceptPool.cases; auto)
  apply (drule spec[of _ pis]; auto)

  apply (erule staticFlowsAcceptPool.cases; auto)
  apply (drule spec[of _ pis]; auto)
  apply (erule staticFlowsAccept.cases; auto)

  apply (rule StaticFlowsAcceptEnv; auto)
  using staticFlowsAcceptEnv_staticFlowsAcceptVal.Unit apply blast
  apply (erule staticFlowsAcceptPool.cases; auto)
  apply (drule spec[of _ pis]; auto)
  apply (erule staticFlowsAcceptEnv.cases; auto)

  apply (erule staticFlowsAcceptPool.cases; auto)
  apply (drule spec[of _ pis]; auto)

  apply (erule notE)
  apply (erule staticFlowsAcceptPool.cases; auto)
  apply (drule spec[of _ pir]; auto)
  apply (erule staticFlowsAccept.cases; auto)

  apply (erule notE)
  apply (erule staticFlowsAcceptPool.cases; auto)
  apply (drule spec[of _ pir]; auto)
  apply (erule staticFlowsAccept.cases; auto)

  apply (rule StaticFlowsAcceptEnv; auto)
  apply (erule staticFlowsAcceptPool.cases; auto)
  apply (drule spec[of _ pis]; auto)
  apply (erule staticFlowsAcceptEnv.cases; auto)
  apply (drule spec[of _ xse]; auto)
  apply (erule staticFlowsAcceptVal.cases; auto)
  apply (erule staticFlowsAcceptEnv.cases; auto)
  apply (erule staticFlowsAcceptPool.cases; auto)
  apply (drule spec[of _ pir]; auto)
  apply (erule staticFlowsAcceptEnv.cases; auto)

  apply (erule staticFlowsAcceptPool.cases; auto)
  apply (drule spec[of _ pir]; auto)

  apply (rule StaticFlowsAcceptEnv; auto)
  apply (erule staticFlowsAcceptPool.cases; auto)
  apply (drule spec[of _ pis]; auto)
  apply (erule staticFlowsAcceptEnv.cases; auto)
  apply (drule spec[of _ xse]; auto)
  apply (erule staticFlowsAcceptVal.cases; auto)
  apply (erule staticFlowsAcceptEnv.cases; auto)
  apply (erule staticFlowsAcceptPool.cases; auto)
  apply (drule spec[of _ pir]; auto)
  apply (erule staticFlowsAcceptEnv.cases; auto)

  apply (erule staticFlowsAcceptPool.cases; auto)
  apply (drule spec[of _ pir]; auto)
  
  apply (erule staticFlowsAcceptPool.cases; auto)+
done

lemma staticFlowsAcceptPoolPreservedDynamicEval:
"
  staticFlowsAcceptPool V F Em \<Longrightarrow>
  (V, C) \<Turnstile>\<^sub>e e0 \<Longrightarrow>
  star_left dynamicEval ([[] \<mapsto> (Stt e0 empty [])], {}) (Em, Hm) \<Longrightarrow>
  dynamicEval (Em, Hm) (E', H') \<Longrightarrow>
  staticFlowsAcceptPool V F [[] \<mapsto> (Stt e0 empty [])] \<Longrightarrow> 
  staticFlowsAcceptPool V F E'
"
apply (erule dynamicEval.cases; auto)
  apply (simp add: staticFlowsAcceptPoolPreservedReturn)
  apply (simp add: staticFlowsAcceptPoolPreservedSeqEval)
  apply (simp add: staticFlowsAcceptPoolPreservedCallEval)
  apply (simp add: staticFlowsAcceptPoolPreservedMkChan)
  apply (simp add: staticFlowsAcceptPoolPreservedSpawn)
  apply (simp add: staticFlowsAcceptPoolPreservedSync)
done


lemma staticFlowsAcceptPoolPreserved':
"
  star_left dynamicEval EH0 EH' \<Longrightarrow>
  (V, C) \<Turnstile>\<^sub>e e0 \<Longrightarrow>
  \<forall> E' H' .
  EH0 = ([[] \<mapsto> (Stt e0 empty [])], {}) \<longrightarrow> 
  EH' = (E', H') \<longrightarrow>
  staticFlowsAcceptPool V F [[] \<mapsto> (Stt e0 empty [])] \<longrightarrow>
  staticFlowsAcceptPool V F E'
"
apply (erule star_left.induct; clarify)
using staticFlowsAcceptPoolPreservedDynamicEval apply metis
done

lemma staticFlowsAcceptPoolPreserved:
"
  staticFlowsAcceptPool V F [[] \<mapsto> (Stt e0 empty [])] \<Longrightarrow>
  (V, C) \<Turnstile>\<^sub>e e0 \<Longrightarrow>
  star dynamicEval ([[] \<mapsto> (Stt e0 empty [])], {}) (E', H') \<Longrightarrow>
  staticFlowsAcceptPool V F E'
"
using star_implies_star_left staticFlowsAcceptPoolPreserved' by fastforce


lemma staticFlowsAcceptToPool:
  "
  staticFlowsAccept V F e \<Longrightarrow>
  staticFlowsAcceptPool V F [[] \<mapsto> (Stt e empty [])]
"
apply (rule staticFlowsAcceptPool.intros; auto)
apply (simp add: StaticFlowsAcceptEnv)
apply (simp add: staticFlowsAcceptStack.Empty)
done

lemma staticLiveChanPoolPreservedReturn: 
"
  staticLiveChanPool V Ln Lx xC [[] \<mapsto> Stt e0 Map.empty []] \<Longrightarrow>
  (V, C) \<Turnstile>\<^sub>e e0 \<Longrightarrow>
  star_left op \<rightarrow> ([[] \<mapsto> Stt e0 Map.empty []], {}) (Em, Hm) \<Longrightarrow>
  staticLiveChanPool V Ln Lx xC Em \<Longrightarrow>
  leaf Em pi \<Longrightarrow>
  Em pi = Some (Stt (Rslt x) env (Ctn xk ek envk # k)) \<Longrightarrow>
  env x = Some v \<Longrightarrow>
  staticLiveChanPool V Ln Lx xC (Em(pi @ [LRtn x] \<mapsto> Stt ek (envk(xk \<mapsto> v)) k))
"
  apply (rule staticLiveChanPool.intros; clarify)
  apply (case_tac "\<pi> = pi @ [LRtn x]"; auto)

    apply (rotate_tac 1)
    apply (erule staticLiveChanPool.cases; auto)
    apply (drule spec[of _ pi]; auto)
    apply (erule staticLiveChanStack.cases; auto)

    apply (rotate_tac 1)
    apply (erule staticLiveChanPool.cases; auto)
    apply (drule spec[of _ pi]; auto)
    apply (erule staticLiveChanStack.cases; auto)
    apply (erule staticLiveChanEnv.cases; auto)
    apply (drule spec[of _ x])
    apply (drule spec[of _ v]; clarsimp)
    apply (erule staticLiveChanEnv.cases; auto)
    apply (rule StaticLiveChanEnv; auto)  

    apply (rotate_tac 1)
    apply (erule staticLiveChanPool.cases; auto)
    apply (drule spec[of _ pi]; auto)
    apply (erule staticLiveChanStack.cases; auto)

    apply (rotate_tac 1)
    apply (erule staticLiveChanPool.cases; auto)

    apply (rotate_tac 1)
    apply (erule staticLiveChanPool.cases; auto)

    apply (rotate_tac 1)
    apply (erule staticLiveChanPool.cases; auto)
done

lemma staticLiveChanPoolPreservedSeqEval:
"
  staticLiveChanPool V Ln Lx xC [[] \<mapsto> Stt e0 Map.empty []] \<Longrightarrow>
  (V, C) \<Turnstile>\<^sub>e e0 \<Longrightarrow>
  star_left op \<rightarrow> ([[] \<mapsto> Stt e0 Map.empty []], {}) (Em, Hm) \<Longrightarrow>
  staticLiveChanPool V Ln Lx xC Em \<Longrightarrow>
  leaf Em pi \<Longrightarrow>
  Em pi = Some (Stt (Bind x b e) env k) \<Longrightarrow>
  seqEval b env v \<Longrightarrow>
  staticLiveChanPool V Ln Lx xC (Em(pi @ [LNxt x] \<mapsto> Stt e (env(x \<mapsto> v)) k))
"
apply (rule staticLiveChanPool.intros; clarify)
apply (case_tac "\<pi> = pi @ [LNxt x]"; auto)
  apply (rotate_tac 1; erule staticLiveChanPool.cases; auto)
  apply (drule spec[of _ pi]; auto)
  apply (erule staticLiveChan.cases; auto)

  apply (rotate_tac 1; erule staticLiveChanPool.cases; auto)
  apply (drule spec[of _ pi]; auto)
  apply (erule seqEval.cases; auto)
    apply (simp add: StaticLiveChanUnit staticLiveChanEnv.simps)
    apply (erule staticLiveChan.cases; clarsimp)
      apply (simp add: StaticLiveChanSendEvt staticLiveChanEnv.simps)
      apply (simp add: StaticLiveChanRecvEvt staticLiveChanEnv.simps)
      apply (simp add: StaticLiveChanPair staticLiveChanEnv.simps)
      apply (simp add: StaticLiveChanLeft staticLiveChanEnv.simps)
      apply (simp add: StaticLiveChanRight staticLiveChanEnv.simps)
      apply (simp add: StaticLiveChanFun staticLiveChanEnv.simps)
    
    apply (frule staticLiveChanEnv.cases; auto)
    apply (drule_tac x = "xp" in spec; auto)
    apply (erule staticLiveChanVal.cases; auto)
    apply (rename_tac xp envp x1 x2)
    apply (rotate_tac -1)
    apply (erule staticLiveChanEnv.cases; auto)
    apply (simp add: staticLiveChanEnv.simps)

    apply (frule staticLiveChanEnv.cases; auto)
    apply (drule_tac x = "xp" in spec; auto)
    apply (erule staticLiveChanVal.cases; auto)
    apply (rename_tac xp envp x1 x2)
    apply (rotate_tac -1)
    apply (erule staticLiveChanEnv.cases; auto)
    apply (simp add: staticLiveChanEnv.simps)
  
  apply (rotate_tac -4)
  apply (erule staticLiveChanPool.cases; auto)
  
  apply (rotate_tac -4)
  apply (erule staticLiveChanPool.cases; auto)

  apply (rotate_tac -4)
  apply (erule staticLiveChanPool.cases; auto)

  apply (rotate_tac 3)
  apply (erule staticLiveChanPool.cases; auto)

  apply (rotate_tac 3)
  apply (erule staticLiveChanPool.cases; auto)

done


lemma staticLiveChanPoolPreservedCall:
"       
  staticLiveChanPool V Ln Lx xC [[] \<mapsto> Stt e0 Map.empty []] \<Longrightarrow>
  (V, C) \<Turnstile>\<^sub>e e0 \<Longrightarrow>
  star_left op \<rightarrow> ([[] \<mapsto> Stt e0 Map.empty []], {}) (Em, Hm) \<Longrightarrow>
  staticLiveChanPool V Ln Lx xC Em \<Longrightarrow>
  leaf Em pi \<Longrightarrow>
  Em pi = Some (Stt (Bind x b e) env k) \<Longrightarrow>
  callEval (b, env) (e', env') \<Longrightarrow>
  staticLiveChanPool V Ln Lx xC (Em(pi @ [LCall x] \<mapsto> Stt e' env' (Ctn x e env # k)))
"
apply (rotate_tac 3)
apply (frule staticLiveChanPool.cases; auto)
apply (drule spec[of _ pi]; auto)
apply (erule callEval.cases; auto; rule staticLiveChanPool.intros; clarify; (case_tac "\<pi> = pi @ [LCall x]"; auto))

    apply (erule staticLiveChan.cases; auto)
   
    apply (frule staticLiveChanEnv.cases; auto)
    apply (drule_tac x = "xs" in spec; auto)
    apply (erule staticLiveChanVal.cases; auto)
    apply (rename_tac xs vl xl xr er envl xl')
    apply (rotate_tac -1)
    apply (erule staticLiveChanEnv.cases; auto)
    apply (drule_tac x = "xl'" in spec; auto)
    apply (simp add: staticLiveChanEnv.simps)

  
  apply (erule staticLiveChan.cases; auto)
    apply (simp add: staticLiveChanStack.Nonempty)
    apply (simp add: staticLiveChanStack.Nonempty)

  apply (frule staticLiveChanPool.cases; auto)
  apply (frule staticLiveChanPool.cases; auto)
  apply (frule staticLiveChanPool.cases; auto)

   apply (erule staticLiveChan.cases; auto)
 
    apply (frule staticLiveChanEnv.cases; auto)
    apply (drule_tac x = "xs" in spec; auto)
    apply (erule staticLiveChanVal.cases; auto)
    apply (rename_tac xs vl xl xr er envr xr')
    apply (rotate_tac -1)
    apply (erule staticLiveChanEnv.cases; auto)
    apply (drule_tac x = "xr'" in spec; auto)
    apply (simp add: staticLiveChanEnv.simps)
  
    
    apply (erule staticLiveChan.cases; auto)
      apply (simp add: staticLiveChanStack.Nonempty)
      apply (simp add: staticLiveChanStack.Nonempty)
  
    apply (frule staticLiveChanPool.cases; auto)
    apply (frule staticLiveChanPool.cases; auto)
    apply (frule staticLiveChanPool.cases; auto)

    apply (erule staticLiveChanEnv.cases; auto)
    apply (drule_tac x = "f" in spec; auto)
    apply (erule staticLiveChanVal.cases; auto)

    
    apply (rule StaticLiveChanEnv; auto)
      apply (erule staticLiveChanEnv.cases; auto)
      apply (erule staticLiveChanEnv.cases; auto)
      apply (erule staticLiveChanEnv.cases; auto)
      apply (erule staticLiveChanEnv.cases; auto)
      apply (drule_tac x = "f" in spec; auto)
      apply (erule staticLiveChanVal.cases; auto)
      apply (simp add: staticLiveChanEnv.simps)

    
    apply (erule staticLiveChan.cases; auto; simp add: staticLiveChanStack.Nonempty)
    apply (erule staticLiveChanPool.cases; auto)+
done

lemma staticLiveChanPreservedMkChan:
"
staticLiveChanPool V Ln Lx xC [[] \<mapsto> Stt e0 Map.empty []] \<Longrightarrow>
(V, C) \<Turnstile>\<^sub>e e0 \<Longrightarrow>
star_left op \<rightarrow> ([[] \<mapsto> Stt e0 Map.empty []], {}) (Em, Hm) \<Longrightarrow>
staticLiveChanPool V Ln Lx xC Em \<Longrightarrow>
leaf Em pi \<Longrightarrow>
Em pi = Some (Stt (Bind x MkChn e) env k) \<Longrightarrow>
staticLiveChanPool V Ln Lx xC (Em(pi @ [LNxt x] \<mapsto> Stt e (env(x \<mapsto> VChn (Ch pi x))) k))
"
apply (rule staticLiveChanPool.Intro; auto)

  apply (rotate_tac 3)
  apply (erule staticLiveChanPool.cases; auto)
  apply (drule spec[of _ pi]; auto)
  apply (erule staticLiveChan.cases; auto)

  apply (rotate_tac 3)
  apply (erule staticLiveChanPool.cases; auto)
  apply (drule spec[of _ pi]; auto)
  apply (simp add: StaticLiveChan staticLiveChanEnv.simps)

  apply (rotate_tac 3)
  apply (erule staticLiveChanPool.cases; auto)

  apply (rotate_tac 3)
  apply (erule staticLiveChanPool.cases; auto)

  apply (rotate_tac 3)
  apply (erule staticLiveChanPool.cases; auto)

  apply (rotate_tac 3)
  apply (erule staticLiveChanPool.cases; auto)

done

lemma staticLiveChanPoolPreservedSpawn:
"
  staticLiveChanPool V Ln Lx xC [[] \<mapsto> Stt e0 Map.empty []] \<Longrightarrow>
  (V, C) \<Turnstile>\<^sub>e e0 \<Longrightarrow>
  star_left op \<rightarrow> ([[] \<mapsto> Stt e0 Map.empty []], {}) (Em, Hm) \<Longrightarrow>
  staticLiveChanPool V Ln Lx xC Em \<Longrightarrow>
  leaf Em pi \<Longrightarrow>
  Em pi = Some (Stt (Bind x (Spwn ec) e) env k) \<Longrightarrow> 
  staticLiveChanPool V Ln Lx xC (Em(pi @ [LNxt x] \<mapsto> Stt e (env(x \<mapsto> VUnt)) k, pi @ [LSpwn x] \<mapsto> Stt ec env []))
"
apply (rule staticLiveChanPool.Intro; auto)

  apply (rotate_tac 3)
  apply (erule staticLiveChanPool.cases; auto)
  apply (drule spec[of _ pi]; auto)
  apply (erule staticLiveChan.cases; auto)

  apply (rotate_tac 3)
  apply (erule staticLiveChanPool.cases; auto)
  apply (simp add: StaticLiveChanUnit staticLiveChanEnv.simps)

  apply (rotate_tac 3)
  apply (erule staticLiveChanPool.cases; auto)

  apply (rotate_tac 3)
  apply (erule staticLiveChanPool.cases; auto)
  apply (drule spec[of _ pi]; auto)
  apply (erule staticLiveChan.cases; auto)

  apply (rotate_tac 3)
  apply (erule staticLiveChanPool.cases; auto)

  apply (simp add: staticLiveChanStack.Empty)

  apply (rotate_tac 3)
  apply (erule staticLiveChanPool.cases; auto)

  apply (rotate_tac 3)
  apply (erule staticLiveChanPool.cases; auto)

  apply (rotate_tac 3)
  apply (erule staticLiveChanPool.cases; auto)

done


(* this might make a nice proof demonstration *)
lemma staticLiveChanPoolPreservedSync:
"
  staticLiveChanPool V Ln Lx xC [[] \<mapsto> Stt e0 Map.empty []] \<Longrightarrow>
  (V, C) \<Turnstile>\<^sub>e e0 \<Longrightarrow>
  star_left op \<rightarrow> ([[] \<mapsto> Stt e0 Map.empty []], {}) (Em, Hm) \<Longrightarrow>
  staticLiveChanPool V Ln Lx xC Em \<Longrightarrow>
  leaf Em pis \<Longrightarrow>
  Em pis = Some (Stt (Bind xs (Sync xse) es) envs ks) \<Longrightarrow>
  envs xse = Some (VClsr (SendEvt xsc xm) envse) \<Longrightarrow>
  leaf Em pir \<Longrightarrow>
  Em pir = Some (Stt (Bind xr (Sync xre) er) envr kr) \<Longrightarrow>
  envr xre = Some (VClsr (RecvEvt xrc) envre) \<Longrightarrow>
  envse xsc = Some (VChn c) \<Longrightarrow>
  envre xrc = Some (VChn c) \<Longrightarrow>
  envse xm = Some vm \<Longrightarrow>
  staticLiveChanPool V Ln Lx xC (Em(pis @ [LNxt xs] \<mapsto> Stt es (envs(xs \<mapsto> VUnt)) ks, pir @ [LNxt xr] \<mapsto> Stt er (envr(xr \<mapsto> vm)) kr))
"
apply (rule staticLiveChanPool.Intro; auto)

  apply (rotate_tac 3)
  apply (erule staticLiveChanPool.cases; auto)
  apply (drule spec[of _ pis]; auto)
  apply (erule staticLiveChan.cases; auto)
  
  apply (rotate_tac 3)
  apply (erule staticLiveChanPool.cases; auto)
  apply (simp add: StaticLiveChanUnit staticLiveChanEnv.simps)

  apply (rotate_tac 3)
  apply (erule staticLiveChanPool.cases; auto)

  apply (rotate_tac 3)
  apply (erule staticLiveChanPool.cases; auto)
  apply (drule spec[of _ pis]; auto)
  apply (erule staticLiveChan.cases; auto)

  apply (rotate_tac 3)
  apply (erule staticLiveChanPool.cases; auto)
  apply (simp add: StaticLiveChanUnit staticLiveChanEnv.simps)

  apply (rotate_tac 3)
  apply (erule staticLiveChanPool.cases; auto)

  apply (rotate_tac 3)
  apply (erule staticLiveChanPool.cases; auto)
  apply (drule spec[of _ pir]; auto)
  apply (erule staticLiveChan.cases; auto)

  apply (rotate_tac 3)
  apply (erule staticLiveChanPool.cases; auto)
  apply (drule spec[of _ pir]; auto)
  apply (erule staticLiveChan.cases; auto)

  apply (rotate_tac 3)
  apply (frule staticLiveChanPool.cases; auto)
  apply (drule spec[of _ pis]; auto)
  apply (rotate_tac -2)
  apply (erule staticLiveChanEnv.cases; auto)
  apply (drule spec[of _ xse]; auto)
  apply (rotate_tac -1)
  apply (erule staticLiveChanVal.cases; auto)
  apply (rotate_tac -1)
  apply (erule staticLiveChanEnv.cases; auto)
  apply (drule spec[of _ xm]; auto)
  apply (erule staticLiveChanPool.cases; auto)
  apply (drule spec[of _ pir]; auto)
  apply (simp add: staticLiveChanEnv.simps)

  apply (rotate_tac 3)
  apply (erule staticLiveChanPool.cases; auto)


  apply (rotate_tac 3)
  apply (frule staticLiveChanPool.cases; auto)
  apply (drule spec[of _ pis]; auto)
  apply (rotate_tac -2)
  apply (erule staticLiveChanEnv.cases; auto)
  apply (drule spec[of _ xse]; auto)
  apply (rotate_tac -1)
  apply (erule staticLiveChanVal.cases; auto)
  apply (rotate_tac -1)
  apply (erule staticLiveChanEnv.cases; auto)
  apply (drule spec[of _ xm]; auto)
  apply (erule staticLiveChanPool.cases; auto)
  apply (drule spec[of _ pir]; auto)
  apply (simp add: staticLiveChanEnv.simps)

  apply (rotate_tac 3)
  apply (erule staticLiveChanPool.cases; auto)

  apply (rotate_tac 3)
  apply (erule staticLiveChanPool.cases; auto)

  apply (rotate_tac 3)
  apply (erule staticLiveChanPool.cases; auto)

  apply (rotate_tac 3)
  apply (erule staticLiveChanPool.cases; auto)

done

lemma staticLiveChanPoolPreservedDynamicEval: 
"
staticLiveChanPool V Ln Lx xC [[] \<mapsto> Stt e0 Map.empty []] \<Longrightarrow>
(V, C) \<Turnstile>\<^sub>e e0 \<Longrightarrow>
star_left op \<rightarrow> ([[] \<mapsto> Stt e0 Map.empty []], {}) (Em, Hm) \<Longrightarrow>
staticLiveChanPool V Ln Lx xC Em \<Longrightarrow>
dynamicEval (Em, Hm) (E, H)  \<Longrightarrow> 
staticLiveChanPool V Ln Lx xC E
"
apply (erule dynamicEval.cases; auto)
  apply (simp add: staticLiveChanPoolPreservedReturn)
  apply (simp add: staticLiveChanPoolPreservedSeqEval)
  apply (simp add: staticLiveChanPoolPreservedCall)
  apply (simp add: staticLiveChanPreservedMkChan)
  apply (simp add: staticLiveChanPoolPreservedSpawn)
  apply (simp add: staticLiveChanPoolPreservedSync)
done


lemma staticLiveChanPoolPreserved':
"
  star_left dynamicEval EH0 EH \<Longrightarrow>
  staticLiveChanPool V Ln Lx xC [[] \<mapsto> (Stt e0 empty [])] \<Longrightarrow>
  (V, C) \<Turnstile>\<^sub>e e0 \<Longrightarrow>
  \<forall> E H .
    EH0 = ([[] \<mapsto> (Stt e0 empty [])], {}) \<longrightarrow>
    EH = (E, H) \<longrightarrow>
    staticLiveChanPool V Ln Lx xC E
"
apply (erule star_left.induct; blast?)
apply (metis surj_pair staticLiveChanPoolPreservedDynamicEval)
done

lemma staticLiveChanPoolPreserved:
  "
  staticLiveChanPool V Ln Lx xC [[] \<mapsto> (Stt e0 empty [])] \<Longrightarrow>
  (V, C) \<Turnstile>\<^sub>e e0 \<Longrightarrow>
  star dynamicEval ([[] \<mapsto> (Stt e0 empty [])], {}) (\<E>', H') \<Longrightarrow>
  staticLiveChanPool V Ln Lx xC \<E>'
"
using star_implies_star_left staticLiveChanPoolPreserved' by fastforce


lemma staticLiveChanToPool:
  "
  staticLiveChan V Ln Lx xC e \<Longrightarrow>
  staticLiveChanPool V Ln Lx xC [[] \<mapsto> (Stt e empty [])]
"
apply (rule staticLiveChanPool.intros; auto)
apply (simp add: staticLiveChanEnv.simps)
apply (simp add: staticLiveChanStack.Empty)
done

lemma dynamicBuiltOnChanComplexNonEmpty:
"
(dynamicBuiltOnChan env chan n \<longrightarrow> env \<noteq> empty) \<and>
(dynamicBuiltOnChanAtom env chan a \<longrightarrow> env \<noteq> empty) \<and>
(dynamicBuiltOnChanComplex env chan c \<longrightarrow> env \<noteq> empty) \<and>
(dynamicBuiltOnChanTm env chan tm \<longrightarrow> env \<noteq> empty)
"
apply (rule dynamicBuiltOnChan_dynamicBuiltOnChanAtom_dynamicBuiltOnChanComplex_dynamicBuiltOnChanTm.induct; auto)
done


lemma staticTraceablePoolSoundDynamicEval:
"
(V, C) \<Turnstile>\<^sub>e e \<Longrightarrow>
star_left op \<rightarrow> ([[] \<mapsto> Stt e Map.empty []], {}) (Em, Hm) \<Longrightarrow>
\<forall>\<pi>' e' env' stack' isEnd. 
Em \<pi>' = Some (Stt e' env' stack') \<longrightarrow>
  dynamicBuiltOnChanTm env' (Ch \<pi>C xC) e' \<longrightarrow>
  staticLiveChanPool V Ln Lx xC Em \<longrightarrow>
  staticFlowsAcceptPool V F Em \<longrightarrow>
  isEnd (tmId e') \<longrightarrow>
  (\<exists>path. pathsCongruentModChan (Em, Hm) (Ch \<pi>C xC) \<pi>' path \<and> staticTraceable F Ln Lx (IdBind xC) isEnd path) \<Longrightarrow>
(Em, Hm) \<rightarrow> (E', H') \<Longrightarrow>
E' \<pi>' = Some (Stt e' env' stack') \<Longrightarrow>
dynamicBuiltOnChanTm env' (Ch \<pi>C xC) e' \<Longrightarrow>
staticLiveChanPool V Ln Lx xC E' \<Longrightarrow>
staticFlowsAcceptPool V F E' \<Longrightarrow>
isEnd (tmId e') \<Longrightarrow> 
\<exists>path. pathsCongruentModChan (E', H') (Ch \<pi>C xC) \<pi>' path \<and> staticTraceable F Ln Lx (IdBind xC) isEnd path
"
apply (erule dynamicEval.cases; clarify)
sorry

lemma staticTraceablePoolSound':
"
star_left dynamicEval EH EH' \<Longrightarrow>
(V, C) \<Turnstile>\<^sub>e e \<Longrightarrow>
\<forall> E' H' \<pi>' e' env' stack' isEnd .
  EH = ([[] \<mapsto> (Stt e empty [])], {}) \<longrightarrow> EH' = (E', H') \<longrightarrow>
  E' \<pi>' = Some (Stt e' env' stack') \<longrightarrow>
  dynamicBuiltOnChanTm env' (Ch \<pi>C xC) e' \<longrightarrow>
  staticLiveChanPool V Ln Lx xC E' \<longrightarrow>
  staticFlowsAcceptPool V F E' \<longrightarrow>
  isEnd (tmId e') \<longrightarrow>
  (\<exists> path .
    pathsCongruentModChan (E', H') (Ch \<pi>C xC) \<pi>' path \<and>
    staticTraceable F Ln Lx (IdBind xC) isEnd path)
"
apply (erule star_left.induct; clarify)
  apply (case_tac "\<pi>' = []"; auto)
  using dynamicBuiltOnChanComplexNonEmpty apply blast
  apply auto
  apply (erule staticTraceablePoolSoundDynamicEval; auto)
done



lemma staticTraceablePoolSound:
"
  \<E>' \<pi>' = Some (Stt e' \<rho>' \<kappa>') \<Longrightarrow>
  dynamicBuiltOnChanTm \<rho>' (Ch \<pi>C xC) e' \<Longrightarrow>
  star dynamicEval ([[] \<mapsto> (Stt e empty [])], {}) (\<E>', H') \<Longrightarrow>
  (V, C) \<Turnstile>\<^sub>e e \<Longrightarrow>
  staticLiveChanPool V Ln Lx xC \<E>' \<Longrightarrow>
  staticFlowsAcceptPool V F \<E>' \<Longrightarrow>
  isEnd (tmId e') \<Longrightarrow>
  (\<exists> path . 
      pathsCongruentModChan (\<E>', H') (Ch \<pi>C xC) \<pi>' path \<and>
      staticTraceable F Ln Lx (IdBind xC) isEnd path)
"
apply (drule star_implies_star_left)
apply (insert staticTraceablePoolSound'[of "([[] \<mapsto> (Stt e empty [])], {})" "(\<E>', H')"])
apply auto
done


lemma staticTraceableSound: "
  \<E>' \<pi>' = Some (Stt e' \<rho>' \<kappa>') \<Longrightarrow>
  dynamicBuiltOnChanTm \<rho>' (Ch \<pi>C xC) e' \<Longrightarrow>
  star dynamicEval ([[] \<mapsto> (Stt e empty [])], {}) (\<E>', H') \<Longrightarrow> 
  (V, C) \<Turnstile>\<^sub>e e \<Longrightarrow>
  staticLiveChan V Ln Lx xC e \<Longrightarrow>
  staticFlowsAccept V F e \<Longrightarrow>
  isEnd (tmId e') \<Longrightarrow>
  \<exists> path .
    pathsCongruentModChan (\<E>', H') (Ch \<pi>C xC) \<pi>' path \<and>
    staticTraceable F Ln Lx (IdBind xC) isEnd path
"
apply (drule staticFlowsAcceptToPool)
apply (drule staticLiveChanToPool)
apply (drule staticTraceablePoolSound; auto?)
apply (erule staticLiveChanPoolPreserved; auto?)
apply (erule staticFlowsAcceptPoolPreserved; auto?)
done

lemma sendEvtBuiltOnChan:
"
env xe = Some (VClsr (SendEvt xsc xm) enve) \<Longrightarrow>
enve xsc = Some (VChn (Ch \<pi>C xC)) \<Longrightarrow>
dynamicBuiltOnChanComplex env (Ch \<pi>C xC) (Sync xe)
"
apply (rule DynBuiltChanSync)
apply (rule DynBuiltChanClosure; auto?)
apply (rule DynBuiltChanSendEvt; auto)
apply (rule DynBuiltChan; auto)
done


lemma staticTraceableSendSound: "
  is_send_path \<E>' (Ch \<pi>C xC) \<pi>Sync \<Longrightarrow>
  star dynamicEval ([[] \<mapsto> (Stt e empty [])], {}) (\<E>', H') \<Longrightarrow> 
  (V, C) \<Turnstile>\<^sub>e e \<Longrightarrow>
  staticLiveChan V Ln Lx xC e \<Longrightarrow>
  staticFlowsAccept V F e \<Longrightarrow>
  \<exists> pathSync .
    (pathsCongruentModChan (\<E>', H') (Ch \<pi>C xC) \<pi>Sync pathSync) \<and> 
    staticTraceable F Ln Lx (IdBind xC) (staticSendSite V e xC) pathSync"
 apply (unfold is_send_path.simps; auto) 
 apply (frule_tac x\<^sub>s\<^sub>c = xsc and \<pi>C = \<pi>C and \<rho>\<^sub>e = enve in staticSendSiteSound; auto?)
  apply (frule staticTraceableSound; auto?)
  using dynamicBuiltOnChan_dynamicBuiltOnChanAtom_dynamicBuiltOnChanComplex_dynamicBuiltOnChanTm.Bind sendEvtBuiltOnChan 
  apply blast
done

(* END PATH SOUND *)


theorem staticOneShotSound': "
  forEveryTwo (staticTraceable F Ln Lx (IdBind xC) (staticSendSite V e xC)) singular \<Longrightarrow>
  staticLiveChan V Ln Lx xC e \<Longrightarrow>
  staticFlowsAccept V F e \<Longrightarrow>
  (V, C) \<Turnstile>\<^sub>e e \<Longrightarrow>
  star dynamicEval ([[] \<mapsto> (Stt e empty [])], {}) (\<E>', H') \<Longrightarrow> 
  forEveryTwo (is_send_path \<E>' (Ch \<pi> xC)) op =
"
 apply (simp add: forEveryTwo.simps singular.simps; auto)
 apply (frule_tac \<pi>Sync = \<pi>1 in staticTraceableSendSound; auto)
 apply (drule_tac x = pathSync in spec)
 apply (frule_tac \<pi>Sync = \<pi>2 in staticTraceableSendSound; auto?)
 apply (drule_tac x = pathSynca in spec)
 apply (erule impE, simp)
 apply (metis is_send_path_implies_nonempty_pool staticInclusiveSound static_equalitySound)
done

theorem staticOneShotSound: "
  \<lbrakk>
    staticOneShot V e xC;
    (V, C) \<Turnstile>\<^sub>e e;
    star dynamicEval ([[] \<mapsto> (Stt e empty [])], {}) (\<E>', H')
  \<rbrakk> \<Longrightarrow>
  one_shot \<E>' (Ch \<pi> xC)
"
 apply (erule staticOneShot.cases; auto)
 apply (unfold one_shot.simps)
 apply (simp add: staticOneShotSound')
done


(*
TO DO LATER:
*)

theorem noncompetitive_send_to_ordered_send: "
  forEveryTwo (staticTraceable F Ln Lx (IdBind xC) (staticSendSite V e xC)) noncompetitive \<Longrightarrow>
  staticLiveChan V Ln Lx xC e \<Longrightarrow>
  staticFlowsAccept V F e \<Longrightarrow>
  (V, C) \<Turnstile>\<^sub>e e \<Longrightarrow>
  star dynamicEval ([[] \<mapsto> (Stt e empty [])], {}) (\<E>', H') \<Longrightarrow>
  forEveryTwo (is_send_path \<E>' (Ch \<pi> xC)) ordered
"
sorry


theorem staticOneToManySound: "
  \<lbrakk>
    staticOneToMany V e xC;
    (V, C) \<Turnstile>\<^sub>e e;
    star dynamicEval ([[] \<mapsto> (Stt e empty [])], {}) (\<E>', H')
  \<rbrakk> \<Longrightarrow>
  fan_out \<E>' (Ch \<pi> xC)
"
 apply (erule staticOneToMany.cases; auto)
 apply (unfold fan_out.simps)
 apply (metis noncompetitive_send_to_ordered_send)
done

lemma noncompetitive_recv_to_ordered_recv:
  "
   forEveryTwo (staticTraceable F Ln Lx (IdBind xC) (staticRecvSite V e xC)) noncompetitive \<Longrightarrow>
   staticFlowsAccept V F e \<Longrightarrow>
   (V, C) \<Turnstile>\<^sub>e e \<Longrightarrow>
   star dynamicEval ([[] \<mapsto> (Stt e empty [])], {}) (\<E>', H') \<Longrightarrow>
   forEveryTwo (is_recv_path \<E>' (Ch \<pi> xC)) ordered
"
sorry


theorem staticManyToOneSound: "
  \<lbrakk>
    staticManyToOne V e xC;
    (V, C) \<Turnstile>\<^sub>e e;
    star dynamicEval ([[] \<mapsto> (Stt e empty [])], {}) (\<E>', H')
  \<rbrakk> \<Longrightarrow>
  fan_in \<E>' (Ch \<pi> xC)
"
 apply (erule staticManyToOne.cases; auto)
 apply (unfold fan_in.simps)
 apply (metis noncompetitive_recv_to_ordered_recv)
done


theorem staticOneToOneSound: "
  \<lbrakk>
    staticOneToOne V e xC;
    (V, C) \<Turnstile>\<^sub>e e;
    star dynamicEval ([[] \<mapsto> (Stt e empty [])], {}) (\<E>', H')
  \<rbrakk> \<Longrightarrow>
  one_to_one \<E>' (Ch \<pi> xC)
"
 apply (erule staticOneToOne.cases; auto)
  apply (unfold one_to_one.simps)
  apply (metis staticManyToOne.intros staticManyToOneSound staticOneToMany.intros staticOneToManySound)
done

end

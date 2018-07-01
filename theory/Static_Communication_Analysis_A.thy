theory Static_Communication_Analysis_A
  imports Main Syntax 
    Dynamic_Semantics Static_Semantics
    Dynamic_Communication_Analysis
    Static_Framework
    Static_Communication_Analysis
begin


inductive simple_flow_set :: "abstract_value_env \<Rightarrow> flow_set \<Rightarrow> exp \<Rightarrow> bool"  where
  Result: "
    simple_flow_set V F (RESULT x)
  " |
  Let_Unit: "
    \<lbrakk>
      {(NLet x , ENext, nodeLabel e)} \<subseteq> F;
      simple_flow_set V F e
    \<rbrakk> \<Longrightarrow>
    simple_flow_set V F (LET x = \<lparr>\<rparr> in e)
  " |
  Let_Chan: "
    \<lbrakk>
      {(NLet x, ENext, nodeLabel e)} \<subseteq> F;
      simple_flow_set V F e
    \<rbrakk> \<Longrightarrow>
    simple_flow_set V F (LET x = CHAN \<lparr>\<rparr> in e)
  " |
  Let_Send_Evt: "
    \<lbrakk>
      {(NLet x, ENext, nodeLabel e)} \<subseteq> F;
      simple_flow_set V F e
    \<rbrakk> \<Longrightarrow>
    simple_flow_set V F (LET x = SEND EVT x\<^sub>c x\<^sub>m in e)
  " |
  Let_Recv_Evt: "
    \<lbrakk>
      {(NLet x, ENext, nodeLabel e)} \<subseteq> F;
      simple_flow_set V F e
    \<rbrakk> \<Longrightarrow>
    simple_flow_set V F (LET x = RECV EVT x\<^sub>c in e)
  " |
  Let_Pair: "
    \<lbrakk>
      {(NLet x, ENext, nodeLabel e)} \<subseteq> F;
      simple_flow_set V F e
    \<rbrakk> \<Longrightarrow>
    simple_flow_set V F (LET x = \<lparr>x\<^sub>1, x\<^sub>2\<rparr> in e)
  " |
  Let_Left: "
    \<lbrakk>
      {(NLet x, ENext, nodeLabel e)} \<subseteq> F;
      simple_flow_set V F e
    \<rbrakk> \<Longrightarrow>
    simple_flow_set V F (LET x = LEFT x\<^sub>p in e)
  " |
  Let_Right: "
    \<lbrakk>
      {(NLet x, ENext, nodeLabel e)} \<subseteq> F;
      simple_flow_set V F e
    \<rbrakk> \<Longrightarrow>
    simple_flow_set V F (LET x = RIGHT x\<^sub>p in e)
  " |
  Let_Abs: "
    \<lbrakk>
      {(NLet x, ENext, nodeLabel e)} \<subseteq> F;
      simple_flow_set V F e\<^sub>b;
      simple_flow_set V F e
    \<rbrakk> \<Longrightarrow>
    simple_flow_set V F (LET x = FN f x\<^sub>p . e\<^sub>b  in e)
  " |
  Let_Spawn: "
    \<lbrakk>
      {
        (NLet x, ENext, nodeLabel e),
        (NLet x, ESpawn, nodeLabel e\<^sub>c)
      } \<subseteq> F;
      simple_flow_set V F e\<^sub>c;
      simple_flow_set V F e
    \<rbrakk> \<Longrightarrow>
    simple_flow_set V F (LET x = SPAWN e\<^sub>c in e)
  " |
  Let_Sync: "
    \<lbrakk>
      {(NLet x, ENext, nodeLabel e)} \<subseteq> F;
      (\<forall> xSC xM xC y.
        {^Send_Evt xSC xM} \<subseteq> V xSE \<longrightarrow>
        {^Chan xC} \<subseteq> V xSC \<longrightarrow>
        {(NLet x, ESend xSE, NLet y)} \<subseteq> F
      );
      simple_flow_set V F e
    \<rbrakk> \<Longrightarrow>
    simple_flow_set V F (LET x = SYNC xSE in e)
  " |
  Let_Fst: "
    \<lbrakk>
      {(NLet x, ENext, nodeLabel e)} \<subseteq> F;
      simple_flow_set V F e
    \<rbrakk> \<Longrightarrow>
    simple_flow_set V F (LET x = FST x\<^sub>p in e)
  " |
  Let_Snd: "
    \<lbrakk>
      {(NLet x, ENext, nodeLabel e)} \<subseteq> F;
      simple_flow_set V F e
    \<rbrakk> \<Longrightarrow>
    simple_flow_set V F (LET x = SND x\<^sub>p in e)
  " |
  Let_Case: "
    \<lbrakk>
      {
        (NLet x, ECall x, nodeLabel e\<^sub>l),
        (NLet x, ECall x, nodeLabel e\<^sub>r),
        (NResult (\<lfloor>e\<^sub>l\<rfloor>), EReturn x, nodeLabel e),
        (NResult (\<lfloor>e\<^sub>r\<rfloor>), EReturn x, nodeLabel e)
      } \<subseteq> F;
      simple_flow_set V F e\<^sub>l;
      simple_flow_set V F e\<^sub>r;
      simple_flow_set V F e
    \<rbrakk> \<Longrightarrow>
    simple_flow_set V F (LET x = CASE x\<^sub>s LEFT x\<^sub>l |> e\<^sub>l RIGHT x\<^sub>r |> e\<^sub>r in e)
  " |
  Let_App: "
    \<lbrakk>
      (\<forall> f' x\<^sub>p e\<^sub>b . ^Abs f' x\<^sub>p e\<^sub>b \<in> V f \<longrightarrow>
        {
          (NLet x, ECall x, nodeLabel e\<^sub>b),
          (NResult (\<lfloor>e\<^sub>b\<rfloor>), EReturn x, nodeLabel e)
        } \<subseteq> F);
      simple_flow_set V F e
    \<rbrakk> \<Longrightarrow>
    simple_flow_set V F (LET x = APP f x\<^sub>a in e)
  "



inductive may_be_live_flow :: "flow_set \<Rightarrow> node_map \<Rightarrow> node_map \<Rightarrow> flow_label \<Rightarrow> bool"  where
  Next: "
    (l, ENext, l') \<in> F \<Longrightarrow>
    \<not> Set.is_empty (Lx l) \<Longrightarrow>
    \<not> Set.is_empty (Ln l') \<Longrightarrow>
    may_be_live_flow F Ln Lx (l, ENext, l')
  " |
  Spawn: "
    (l, ESpawn, l') \<in> F \<Longrightarrow>
    \<not> Set.is_empty (Lx l) \<Longrightarrow>
    \<not> Set.is_empty (Ln l') \<Longrightarrow>
    may_be_live_flow F Ln Lx (l, ESpawn, l')
  " |
  Call_Live_Outer: "
    (l, ECall x, l') \<in> F \<Longrightarrow>
    \<not> Set.is_empty (Lx l) \<Longrightarrow>
    may_be_live_flow F Ln Lx (l, ECall x, l')
  " |
  Call_Live_Inner: "
    (l, ECall x, l') \<in> F \<Longrightarrow>
    \<not> Set.is_empty (Ln l') \<Longrightarrow>
    may_be_live_flow F Ln Lx (l, ECall x, l')
  " |
  Return: "
    (l, EReturn x, l') \<in> F \<Longrightarrow>
    \<not> Set.is_empty (Ln l') \<Longrightarrow>
    may_be_live_flow F Ln Lx (l, EReturn x, l')
  " |
  Send: "
    ((NLet xSend), ESend xE, (NLet xRecv)) \<in> F \<Longrightarrow>
    {xE} \<subseteq> (Ln (NLet xSend)) \<Longrightarrow>
    may_be_live_flow F Ln Lx ((NLet xSend), ESend xE, (NLet xRecv))
  "

inductive may_be_path :: "abstract_value_env \<Rightarrow> flow_set \<Rightarrow> node_map \<Rightarrow> node_map \<Rightarrow> node_label \<Rightarrow> (node_label \<Rightarrow> bool) \<Rightarrow> static_path \<Rightarrow> bool" where
  Empty: "
    isEnd start \<Longrightarrow>
    may_be_path V F Ln Lx start isEnd []
  " (*|
  Edge: "
    isEnd end \<Longrightarrow>
    may_be_live_flow F Ln Lx (start, edge, end) \<Longrightarrow>
    may_be_path V F Ln Lx start isEnd [(start, edge)]
  " |
  Step: "
    may_be_path V F Ln Lx middle isEnd ((middle, edge') # path) \<Longrightarrow>
    may_be_live_flow F Ln Lx (start, edge, middle) \<Longrightarrow>
    may_be_path V F Ln Lx start isEnd ((start, edge) # (middle, edge') # path)
  " |

  Pre_Return: "
    may_be_path V F Ln Lx (NResult y) isEnd ((NResult y, EReturn x) # post) \<Longrightarrow>
    may_be_path  F (NResult y) pre \<Longrightarrow>
    \<not> static_balanced (pre @ [(NResult y, EReturn x)]) \<Longrightarrow>
    \<not> Set.is_empty (Lx (NLet x)) \<Longrightarrow>
    path = pre @ (NResult y, EReturn x) # post \<Longrightarrow>
    may_be_path V F Ln Lx start isEnd path
  "*)



inductive may_be_send_node_label :: "abstract_value_env \<Rightarrow> exp \<Rightarrow> var \<Rightarrow> node_label \<Rightarrow> bool" where
  Sync: "
    {^Chan xC} \<subseteq> V xSC \<Longrightarrow>
    {^Send_Evt xSC xM} \<subseteq> V xE \<Longrightarrow>
    is_super_exp e (LET x = SYNC xE in e') \<Longrightarrow>
    may_be_send_node_label V e xC (NLet x)
  "

inductive may_be_recv_node_label :: "abstract_value_env \<Rightarrow> exp \<Rightarrow> var \<Rightarrow> node_label \<Rightarrow> bool" where
  Sync: "
    {^Chan xC} \<subseteq> V xRC \<Longrightarrow>
    {^Recv_Evt xRC} \<subseteq> V xE \<Longrightarrow>
    is_super_exp e (LET x = SYNC xE in e') \<Longrightarrow>
    may_be_recv_node_label V e xC (NLet x)
  "



inductive may_be_inclusive :: "static_path \<Rightarrow> static_path \<Rightarrow> bool" (infix "\<asymp>" 55) where
  Prefix1: "
    prefix \<pi>\<^sub>1 \<pi>\<^sub>2 \<Longrightarrow>
    \<pi>\<^sub>1 \<asymp> \<pi>\<^sub>2
  " |
  Prefix2: "
    prefix \<pi>\<^sub>2 \<pi>\<^sub>1 \<Longrightarrow>
    \<pi>\<^sub>1 \<asymp> \<pi>\<^sub>2
  " |
  Spawn1: "
    \<pi> @ (NLet x, ESpawn) # \<pi>\<^sub>1 \<asymp> \<pi> @ (NLet x, ENext) # \<pi>\<^sub>2
  " |
  Spawn2: "
    \<pi> @ (NLet x, ENext) # \<pi>\<^sub>1 \<asymp> \<pi> @ (NLet x, ESpawn) # \<pi>\<^sub>2
  "

lemma may_be_inclusive_commut: "
  path\<^sub>1 \<asymp> path\<^sub>2 \<Longrightarrow> path\<^sub>2 \<asymp> path\<^sub>1
"
 apply (erule may_be_inclusive.cases; auto)
  apply (simp add: Prefix2)
  apply (simp add: Prefix1)
  apply (simp add: Spawn2)
  apply (simp add: Spawn1)
done


lemma may_be_inclusive_preserved_under_unordered_extension: "
  \<not> prefix path\<^sub>1 path\<^sub>2 \<Longrightarrow> \<not> prefix path\<^sub>2 path\<^sub>1 \<Longrightarrow> path\<^sub>1 \<asymp> path\<^sub>2 \<Longrightarrow> path\<^sub>1 @ [l] \<asymp> path\<^sub>2
"
 apply (erule may_be_inclusive.cases; auto)
  apply (simp add: Spawn1)
  apply (simp add: Spawn2)
done

lemma may_be_inclusive_preserved_under_unordered_double_extension: "
  path\<^sub>1 \<asymp> path\<^sub>2 \<Longrightarrow> \<not> prefix path\<^sub>1 path\<^sub>2 \<Longrightarrow> \<not> prefix path\<^sub>2 path\<^sub>1 \<Longrightarrow> path\<^sub>1 @ [l1] \<asymp> path\<^sub>2 @ [l2]
"
by (metis may_be_inclusive_commut may_be_inclusive_preserved_under_unordered_extension prefix_append prefix_def)


inductive singular :: "static_path \<Rightarrow> static_path \<Rightarrow> bool" where
  equal: "
    \<pi>\<^sub>1 = \<pi>\<^sub>2 \<Longrightarrow> 
    singular \<pi>\<^sub>1 \<pi>\<^sub>2
  " |
  exclusive: "
    \<not> (\<pi>\<^sub>1 \<asymp> \<pi>\<^sub>2) \<Longrightarrow> 
    singular \<pi>\<^sub>1 \<pi>\<^sub>2
  "

inductive noncompetitive :: "static_path \<Rightarrow> static_path \<Rightarrow> bool" where
  ordered: "
    ordered \<pi>\<^sub>1 \<pi>\<^sub>2 \<Longrightarrow> 
    noncompetitive \<pi>\<^sub>1 \<pi>\<^sub>2
  " |
  exclusive: "
    \<not> (\<pi>\<^sub>1 \<asymp> \<pi>\<^sub>2) \<Longrightarrow> 
    noncompetitive \<pi>\<^sub>1 \<pi>\<^sub>2
  "



inductive static_one_shot :: "abstract_value_env \<Rightarrow> exp \<Rightarrow> var \<Rightarrow> bool" where
  Sync: "
    every_two_static_paths (may_be_path V F Ln Lx (NLet xC) (may_be_send_node_label V e xC)) singular \<Longrightarrow>
    static_one_shot V e xC 
  "

inductive static_one_to_one :: "abstract_value_env \<Rightarrow> exp \<Rightarrow> var \<Rightarrow> bool" where
  Sync: "
    every_two_static_paths (may_be_path V F Ln Lx (NLet xC) (may_be_send_node_label V e xC)) noncompetitive \<Longrightarrow>
    every_two_static_paths (may_be_path V F Ln Lx (NLet xC) (may_be_recv_node_label V e xC)) noncompetitive \<Longrightarrow>
    simple_flow_set V F e \<Longrightarrow>
    static_one_to_one V e xC 
  "

inductive static_fan_out :: "abstract_value_env \<Rightarrow> exp \<Rightarrow> var \<Rightarrow> bool" where
  Sync: "
    every_two_static_paths (may_be_path V F Ln Lx (NLet xC) (may_be_send_node_label V e xC)) noncompetitive \<Longrightarrow>
    simple_flow_set V F e \<Longrightarrow>
    static_fan_out V e xC 
  "

inductive static_fan_in :: "abstract_value_env \<Rightarrow> exp \<Rightarrow> var \<Rightarrow> bool" where
  Sync: "
    every_two_static_paths (may_be_path V F Ln Lx (NLet xC) (may_be_recv_node_label V e xC)) noncompetitive \<Longrightarrow>
    simple_flow_set V F e \<Longrightarrow>
    static_fan_in V e xC 
  "

end

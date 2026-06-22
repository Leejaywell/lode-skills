# Go 指令模板

> 由 lode-go 生成。一条 Go = 把目标交给 AI 自驱执行的入口。
> 让 AI 结合上下文替你填，你扫一眼点发送即可。

```
/go 完成 <项目> 的 <dev-plan Phase N / Face N>：<一句话目标>

完成标准：
1. <可程序判断，如：成为可运行的 Electron + Vite + React + TS 工程>
2. <复用已有静态原型代码，而非凭空重写>
3. .lode/<project>/verify.sh 退出码为 0（编译零报错 / 测试全过）
4. 审查通过并写入 .lode/<project>/review-passed

验收方式：
- 运行 verify.sh 的关键输出（编译 + 测试）
- 列出新建/修改的文件
- 说明复用了哪些原型文件
- 四步审计报告：编译验证 / 测试完整性 / Code Review / 功能测试

约束：
- 不改 product-spec.md 和 design-brief.md，除非发现必须回写的矛盾
- 不动已定的 UI 基线
- 不碰本阶段之外的业务功能
- 每个 Face 审过后可做本地 commit 作回滚点；但**不 push、不删原型文件**，除非用户确认

执行策略：目标导向，一条路走不通就换多种方法都试过才停；长任务持续推进直到达成 Go。熔断：同一 Face 连续失败 ≥3 次、或超出 token 预算，就停下找人，不无限重试。
```

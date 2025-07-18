import Logger from '../common/utils/Logger'; // 引入日志工具

// 1. 定义Builder模式的导航入口函数
@Builder
export function FocusRecordBuilder() {
  FocusRecordPage(); // 直接渲染组件
}

// 2. 增强版FocusRecordPage组件
@Component
export struct FocusRecordPage {
  // 导航路径栈（用于复杂导航场景）
  private pathStack: NavPathStack = new NavPathStack();

  // 页面构建
  build() {
    NavDestination() {
      Column() {
        Text("这里是专注记录内容")
          .fontSize(18)
          .onClick(() => {
            Logger.debug("专注记录内容被点击"); // 使用统一日志工具
          })
      }
      .width('100%')
      .height('100%')
    }
    .title('专注记录')
    .onBackPressed(() => this.handleBackPress()) // 提取返回逻辑
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack; // 获取导航栈引用
      Logger.info("专注记录页初始化完成"); // 记录生命周期事件
    })
  }

  // 3. 私有方法封装返回逻辑
  private handleBackPress(): boolean {
    Logger.debug("触发返回个人中心操作");
    // 可在此处添加业务逻辑（如数据保存检查）
    return false; // 允许默认返回行为
  }
}
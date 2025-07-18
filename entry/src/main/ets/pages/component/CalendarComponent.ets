// CalendarComponent.ets
@Preview
@Component
export struct CalendarComponent {
  @State currentDate: Date = new Date();          // 当前显示的月份
  @Link selectedDate: Date         // 用户选中的日期
  @State showDateDialog: boolean = false;        // 是否显示日期对话框


  // 获取某个月份的天数
  private getDaysInMonth(date: Date): number {
    return new Date(date.getFullYear(), date.getMonth() + 1, 0).getDate();
  }

  // 获取某个月份第一天是星期几
  private getFirstDayOfMonth(date: Date): number {
    return new Date(date.getFullYear(), date.getMonth(), 1).getDay();
  }

  // 检查是否是今天
  private isToday(date: Date): boolean {
    const today = new Date();
    return date.toDateString() === today.toDateString();
  }

  // 检查是否是选中的日期
  private isSelected(date: Date): boolean {
    return date.toDateString() === this.selectedDate.toDateString();
  }

  // 切换到上个月
  private previousMonth(): void {
    this.currentDate = new Date(this.currentDate.getFullYear(), this.currentDate.getMonth() - 1, 1);
  }

  // 切换到下个月
  private nextMonth(): void {
    this.currentDate = new Date(this.currentDate.getFullYear(), this.currentDate.getMonth() + 1, 1);
  }

  // 选择日期
  private selectDate(day: number): void {
    this.selectedDate = new Date(this.currentDate.getFullYear(), this.currentDate.getMonth(), day);
    this.showDateDialog = true;
  }

  // 构建日历网格数据
  private buildCalendarGrid(): Date[][] {
    const grid: Date[][] = [];
    const daysInMonth = this.getDaysInMonth(this.currentDate);
    const firstDay = this.getFirstDayOfMonth(this.currentDate);

    let currentWeek: Date[] = [];

    // 添加上个月的日期
    const prevMonth = new Date(this.currentDate.getFullYear(), this.currentDate.getMonth() - 1, 1);
    const daysInPrevMonth = this.getDaysInMonth(prevMonth);

    for (let i = firstDay - 1; i >= 0; i--) {
      currentWeek.push(new Date(prevMonth.getFullYear(), prevMonth.getMonth(), daysInPrevMonth - i));
    }

    // 添加当前月的日期
    for (let day = 1; day <= daysInMonth; day++) {
      currentWeek.push(new Date(this.currentDate.getFullYear(), this.currentDate.getMonth(), day));

      if (currentWeek.length === 7) {
        grid.push(currentWeek);
        currentWeek = [];
      }
    }

    // 添加下个月的日期
    const nextMonth = new Date(this.currentDate.getFullYear(), this.currentDate.getMonth() + 1, 1);
    let nextMonthDay = 1;
    while (currentWeek.length < 7) {
      currentWeek.push(new Date(nextMonth.getFullYear(), nextMonth.getMonth(), nextMonthDay));
      nextMonthDay++;
    }

    if (currentWeek.length > 0) {
      grid.push(currentWeek);
    }

    return grid;
  }

  // 日期对话框构建器
  @Builder
  dateDialogBuilder() {
    Column() {
      // 对话框标题
      Text(`${this.selectedDate.getFullYear()}年${this.selectedDate.getMonth() + 1}月${this.selectedDate.getDate()}日`)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 20 })

      Button('关闭')
        .backgroundColor('#f0f0f0')
        .fontColor(Color.Black)
        .onClick(() => {
          this.showDateDialog = false;
        })
        .width('100%')
    }
    .padding(20)
    .width('100%')
  }

  build() {
    Column() {
      // 日历头部 - 月份导航
      Row() {
        Button('<')
          .onClick(() => this.previousMonth())
          .backgroundColor('#f0f0f0')
          .fontColor(Color.Black)
          .width(40)
          .height(40)

        Text(`${this.currentDate.getFullYear()}年${this.currentDate.getMonth() + 1}月`)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Button('>')
          .onClick(() => this.nextMonth())
          .backgroundColor('#f0f0f0')
          .fontColor(Color.Black)
          .width(40)
          .height(40)
      }
      .width('100%')
      .margin({ bottom: 20 })

      // 星期标题
      Row() {
        ForEach(['日', '一', '二', '三', '四', '五', '六'], (day: string) => {
          Text(day)
            .fontSize(14)
            .fontColor('#666')
            .textAlign(TextAlign.Center)
            .width(`${100/7}%`)
            .height(30)
        })
      }
      .width('100%')

      // 日历网格
      Column() {
        ForEach(this.buildCalendarGrid(), (week: Date[]) => {
          Row() {
            ForEach(week, (date: Date) => {
              Column() {
                if (date.getMonth() === this.currentDate.getMonth()) {
                  // 当前月份的日期
                  Text(date.getDate().toString())
                    .fontSize(16)
                    .fontColor(this.isToday(date) ? Color.White : Color.Black)
                    .textAlign(TextAlign.Center)
                    .width(30)
                    .height(30)
                    .backgroundColor(this.isToday(date) ? Color.Blue :
                      this.isSelected(date) ? '#E3F2FD' : Color.Transparent)
                    .borderRadius(15)
                    .onClick(() => this.selectDate(date.getDate()))
                } else {
                  // 其他月份的日期（灰色显示）
                  Text(date.getDate().toString())
                    .fontSize(16)
                    .fontColor('#ccc')
                    .textAlign(TextAlign.Center)
                    .width(30)
                    .height(30)
                }
              }
              .width(`${100/7}%`)
              .height(50)
              .justifyContent(FlexAlign.Center)
            })
          }
          .width('100%')
        })
      }
      .width('100%')
    }
    .padding(20)
    .width('100%')
    .height('100%')
    .bindSheet($$this.showDateDialog, this.dateDialogBuilder(), {
      height: 200,
      dragBar: true,
      backgroundColor: Color.White
    })
  }
}
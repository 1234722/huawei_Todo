// CalendarComponent.ets
@Component
export struct CalendarComponent {
  @State currentDate: Date = new Date();          // 当前显示的月份
  @State selectedDate: Date = new Date();         // 用户选中的日期
  @State showEventDialog: boolean = false;        // 是否显示事件对话框
  @State eventManager: EventManager = new EventManager(); // 事件管理器
  @State newEventTitle: string = '';              // 新事件标题
  @State newEventDescription: string = '';        // 新事件描述
  @State newEventTime: string = '09:00';          // 新事件时间

  // 获取某个月份的天数
  private getDaysInMonth(date: Date): number {
    return new Date(date.getFullYear(), date.getMonth() + 1, 0).getDate();
  }

  // 获取某个月份第一天是星期几
  private getFirstDayOfMonth(date: Date): number {
    return new Date(date.getFullYear(), date.getMonth(), 1).getDay();
  }

  // 格式化日期为YYYY-MM-DD字符串
  private formatDate(date: Date): string {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
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

  // 检查指定日期是否有事件
  private hasEvents(date: Date): boolean {
    const dateStr = this.formatDate(date);
    return this.eventManager.getEventsByDate(dateStr).length > 0;
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
    this.showEventDialog = true;
  }

  // 添加新事件
  private addEvent(): void {
    if (this.newEventTitle.trim()) {
      const event: EventItem = {
        id: Date.now().toString(),
        title: this.newEventTitle,
        description: this.newEventDescription,
        date: this.formatDate(this.selectedDate),
        time: this.newEventTime,
        color: '#007AFF'
      };
      this.eventManager.addEvent(event);
      this.newEventTitle = '';
      this.newEventDescription = '';
      this.newEventTime = '09:00';
    }
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

  // 事件对话框构建器
  @Builder
  eventDialogBuilder() {
    Column() {
      // 对话框标题
      Text(`${this.selectedDate.getFullYear()}年${this.selectedDate.getMonth() + 1}月${this.selectedDate.getDate()}日`)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 20 })

      // 显示当日事件
      Text('当日事件')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 10 })

      List() {
        ForEach(this.eventManager.getEventsByDate(this.formatDate(this.selectedDate)),
          (event: EventItem) => {
            ListItem() {
              Row() {
                Circle({ width: 8, height: 8 })
                  .fill(event.color || '#007AFF')
                  .margin({ right: 10 })

                Column() {
                  Text(event.title)
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)

                  if (event.description) {
                    Text(event.description)
                      .fontSize(12)
                      .fontColor('#666')
                      .margin({ top: 2 })
                  }

                  Text(event.time)
                    .fontSize(12)
                    .fontColor('#999')
                    .margin({ top: 2 })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)

                Button('删除')
                  .fontSize(12)
                  .backgroundColor('#FF6B6B')
                  .fontColor(Color.White)
                  .width(60)
                  .height(30)
                  .onClick(() => {
                    this.eventManager.deleteEvent(event.id);
                  })
              }
              .width('100%')
              .padding(10)
              .backgroundColor('#f8f9fa')
              .borderRadius(8)
              .margin({ bottom: 8 })
            }
          }
        )
      }
      .height(120)
      .width('100%')

      // 添加新事件
      Divider().margin({ top: 20, bottom: 20 })

      Text('添加新事件')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 10 })

      TextInput({ placeholder: '事件标题' })
        .onChange((value: string) => {
          this.newEventTitle = value;
        })
        .margin({ bottom: 10 })

      TextInput({ placeholder: '事件描述（可选）' })
        .onChange((value: string) => {
          this.newEventDescription = value;
        })
        .margin({ bottom: 10 })

      Row() {
        Text('时间：')
          .fontSize(14)
          .margin({ right: 10 })

        TextInput({ placeholder: '09:00', text: this.newEventTime })
          .onChange((value: string) => {
            this.newEventTime = value;
          })
          .width(100)
      }
      .alignItems(VerticalAlign.Center)
      .alignSelf(ItemAlign.Start)
      .margin({ bottom: 20 })

      Row() {
        Button('取消')
          .backgroundColor('#f0f0f0')
          .fontColor(Color.Black)
          .onClick(() => {
            this.showEventDialog = false;
            this.newEventTitle = '';
            this.newEventDescription = '';
            this.newEventTime = '09:00';
          })
          .layoutWeight(1)
          .margin({ right: 10 })

        Button('添加')
          .backgroundColor('#007AFF')
          .fontColor(Color.White)
          .onClick(() => {
            this.addEvent();
            this.showEventDialog = false;
          })
          .layoutWeight(1)
          .enabled(this.newEventTitle.trim().length > 0)
      }
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

                  // 事件指示器
                  if (this.hasEvents(date)) {
                    Circle({ width: 6, height: 6 })
                      .fill('#FF6B6B')
                      .margin({ top: 2 })
                  }
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
    .bindSheet($$this.showEventDialog, this.eventDialogBuilder(), {
      height: 400,
      dragBar: true,
      backgroundColor: Color.White
    })
  }
}

// 事件数据模型
interface EventItem {
  id: string;          // 事件ID
  title: string;       // 事件标题
  description?: string; // 事件描述（可选）
  date: string;        // 日期（YYYY-MM-DD格式）
  time: string;        // 时间（HH:mm格式）
  color?: string;      // 事件颜色（可选）
}

// 事件管理类
class EventManager {
  private events: EventItem[] = [];

  // 添加事件
  addEvent(event: EventItem): void {
    this.events.push(event);
  }

  // 获取指定日期的事件
  getEventsByDate(date: string): EventItem[] {
    return this.events.filter(event => event.date === date);
  }

  // 删除事件
  deleteEvent(id: string): void {
    this.events = this.events.filter(event => event.id !== id);
  }

  // 更新事件
  updateEvent(updatedEvent: EventItem): void {
    const index = this.events.findIndex(event => event.id === updatedEvent.id);
    if (index !== -1) {
      this.events[index] = updatedEvent;
    }
  }

  // 获取所有事件
  getAllEvents(): EventItem[] {
    return this.events;
  }
}
export function getFormattedDate(): string {
  // 获取当前时间戳并转换为Date对象
  const date = new Date();

  // 提取并格式化年、月、日
  const year = date.getFullYear();
  const month = (date.getMonth() + 1).toString().padStart(2, '0');
  const day = date.getDate().toString().padStart(2, '0');

  // 拼接为日期字符串
  return `${year}-${month}-${day}`;
}
//时间转换成秒
export function timeToSeconds(timeStr: string): number {
  const parts = timeStr.split('-').map(Number);
  const hours = parts[0];
  const minutes = parts[1];
  const seconds = parts[2];
  return hours * 3600 + minutes * 60 + seconds;
}
// 获取格式化时间
export function getFormattedTime(): string {
  const now = new Date()
  return `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}:${now.getSeconds().toString().padStart(2, '0')}`
}

// 格式化倒计时显示
export function formatTime(seconds: number): string {
  const mins = Math.floor(seconds / 60)
  const secs = seconds % 60
  return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`
}

export function toggleTimer(duration: number, onSeconds: (now: number) => void = () => {}, onEnd: () => void = () => {}) {
  let remainingTime: number = duration
  let lastTickTime: number = 0
  let timerId = setInterval(() => {
    const now = new Date().getTime() // 获取当前时间
    const elapsed = lastTickTime > 0 ? Math.floor((now - lastTickTime) / 1000) : 1 // 计算经过的秒数
    remainingTime = Math.max(0, remainingTime - elapsed) // 更新剩余时间
    onSeconds(remainingTime)
    lastTickTime = now // 更新最后记录时间
    if (remainingTime <= 0) {
      clearInterval(timerId) // 清除计时器
      onEnd()
    }
  }, 1000) // 设置定时器间隔为1秒
}

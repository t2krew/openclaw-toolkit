# 如何添加收款码图片

## 步骤

1. 将你的两张收款码图片重命名为：
   - `wechat-pay.jpg` (微信支付)
   - `alipay.jpg` (支付宝)

2. 将这两张图片复制到项目的 `images` 目录：
   ```bash
   cp /Users/krew/Desktop/微信图片_20260306030357_36_209.jpg /root/openclaw-tool/images/wechat-pay.jpg
   cp /Users/krew/Desktop/微信图片_20260306030358_37_209.jpg /root/openclaw-tool/images/alipay.jpg
   ```

3. 或者手动复制：
   - 打开 `/root/openclaw-tool/images/` 目录
   - 将图片复制进去并重命名

## 已完成的工作

✅ 创建了 `images` 目录
✅ 在 README.md 中添加了"Buy Me a Coffee"模块
✅ 在 README_CN.md 中添加了"请喝咖啡"模块
✅ 配置了图片引用路径

## 图片要求

- 格式：JPG/PNG
- 建议尺寸：200x200 像素左右
- 文件大小：建议小于 500KB

## 完成后

将图片添加到 images 目录后，运行：
```bash
cd /root/openclaw-tool
git add images/
git add README.md README_CN.md
git commit -m "docs: add donation QR codes"
git push
```

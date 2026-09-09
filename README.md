# NextDNS Free Fire Vietnam Blocker

Script và cấu hình để chặn máy chủ Free Fire Việt Nam sử dụng NextDNS.

## Tính năng

- ✅ Chặn domain Free Fire chính thức
- ✅ Chặn các CDN và server của Garena tại Việt Nam
- ✅ Hỗ trợ cả IPv4 và IPv6
- ✅ Dễ dàng tích hợp với NextDNS

## Danh sách Domain bị chặn

### Domain chính
- `freefiremobile.com`
- `ff.garena.com`
- `freefireind.in`
- `*.garena.com`
- `*.akamaized.net` (CDN)

### IP ranges Garena Southeast Asia
- `202.81.96.0/22`
- `202.81.112.0/22`
- `148.222.66.0/24`
- `202.81.99.0/24`
- `202.81.117.0/24`
- `202.81.123.0/24`
- `202.81.118.0/24`
- `143.92.120.0/22`
- `125.212.198.39`

## Cách sử dụng

### 1. Với NextDNS Web Interface
1. Đăng nhập vào [NextDNS Dashboard](https://my.nextdns.io/)
2. Chọn Profile của bạn
3. Vào **Security** → **Threat Intelligence**
4. Thêm các domain từ file `blocked-domains.txt` vào **Custom Rules** hoặc **Allowlist/Blocklist**

### 2. Với NextDNS CLI
```bash
# Sử dụng file cấu hình
nextdns config -profile=YOUR_PROFILE_ID < blocklist-config.txt
```

### 3. Thủ công
1. Copy danh sách domain từ `blocked-domains.txt`
2. Thêm vào NextDNS Settings → Blocklist
3. Lưu thay đổi

## File trong Repository

- `blocked-domains.txt` - Danh sách domain cần chặn
- `blocked-ips.txt` - Danh sách IP ranges cần chặn
- `nextdns-config.json` - Cấu hình NextDNS (JSON format)
- `setup.sh` - Script tự động cấu hình (Linux/Mac)

## Lưu ý

- ⚠️ Chặn Free Fire sẽ ngăn chặn truy cập hoàn toàn đến game
- ⚠️ Một số domain có thể được chia sẻ với các dịch vụ khác
- ℹ️ Danh sách có thể cần cập nhật khi Garena thay đổi server

## Kiểm tra chặn

```bash
# Kiểm tra domain
nslookup freefiremobile.com

# Kiểm tra IP
ping 202.81.96.1
```

Nếu không có phản hồi, chặn đã thành công! ✅

## Liên hệ

Nếu có vấn đề hoặc cần cập nhật danh sách, vui lòng tạo Issue.

---

**Disclaimer**: Repository này được tạo cho mục đích quản lý mạng nội bộ. Vui lòng sử dụng một cách có trách nhiệm.
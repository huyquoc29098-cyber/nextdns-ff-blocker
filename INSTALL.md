# Hướng dẫn cài đặt NextDNS Free Fire Blocker

## Yêu cầu hệ thống

- **Hệ điều hành**: Linux, macOS hoặc Windows (WSL)
- **Quyền truy cập**: Root/Admin
- **NextDNS Account**: Đã đăng ký tại [NextDNS](https://my.nextdns.io/)
- **Kết nối Internet**: Ổn định

## Cách cài đặt

### Phương pháp 1: Tự động (Linux/macOS)

```bash
# Clone repository
git clone https://github.com/huyquoc29098-cyber/nextdns-ff-blocker.git
cd nextdns-ff-blocker

# Cấp quyền thực thi
chmod +x setup.sh

# Chạy script cài đặt
sudo ./setup.sh
```

### Phương pháp 2: Cài đặt thủ công

#### Bước 1: Cài đặt NextDNS CLI

**Linux:**
```bash
sh -c 'sh -c "$(curl -sL https://nextdns.io/install)"'
```

**macOS:**
```bash
brew install nextdns
# hoặc
sh -c 'sh -c "$(curl -sL https://nextdns.io/install)"'
```

**Windows (WSL):**
```bash
sh -c 'sh -c "$(curl -sL https://nextdns.io/install)"'
```

#### Bước 2: Lấy NextDNS Profile ID

1. Truy cập [NextDNS Dashboard](https://my.nextdns.io/)
2. Đăng nhập với tài khoản của bạn
3. Chọn Profile
4. Copy **Profile ID** (ví dụ: `a1b2c3d4`)

#### Bước 3: Cấu hình NextDNS

```bash
sudo nextdns config -profile YOUR_PROFILE_ID
```

Thay `YOUR_PROFILE_ID` bằng ID của bạn.

#### Bước 4: Thêm Blocklist

**Cách 1: Qua Web Interface**

1. Truy cập https://my.nextdns.io/
2. Chọn Profile
3. Vào mục **Denylist** → **Custom Rules**
4. Copy nội dung từ file `blocked-domains.txt`
5. Dán vào ô nhập liệu
6. Nhấn **Add**

**Cách 2: Qua API (nếu có API Key)**

```bash
# Đặt API Key
export NEXTDNS_API_KEY="your_api_key_here"

# Thêm domains
while IFS= read -r domain; do
    [[ "$domain" =~ ^#.*$ ]] && continue
    [[ -z "$domain" ]] && continue
    curl -X POST "https://api.nextdns.io/profiles/YOUR_PROFILE_ID/denylist" \
         -H "Authorization: Bearer $NEXTDNS_API_KEY" \
         -H "Content-Type: application/json" \
         -d "{\"data\": \"$domain\"}"
done < blocked-domains.txt
```

#### Bước 5: Khởi động NextDNS

```bash
# Linux/macOS
sudo nextdns start

# Kiểm tra trạng thái
nextdns status
```

## Kiểm tra hoạt động

### Test DNS Resolution

```bash
# Kiểm tra nếu domain bị chặn
nslookup freefiremobile.com

# Nếu kết quả hiển thị "NXDOMAIN" = thành công ✓
```

### Kiểm tra qua NextDNS Dashboard

1. Vào https://my.nextdns.io/
2. Chọn Profile
3. Xem tab **Analytics** để theo dõi request bị chặn
4. Tìm Free Fire domains trong **Blocked** section

### Kiểm tra trên thiết bị khác

```bash
# Từ máy tính/điện thoại khác
nslookup freefiremobile.com 8.8.8.8      # Google DNS (không chặn)
nslookup freefiremobile.com <YOUR_NEXTDNS_IP>  # NextDNS (chặn)
```

## Cấu hình cho các thiết bị

### DNS Settings

**NextDNS Primary**: `45.90.28.0`  
**NextDNS Secondary**: `45.90.30.0`

hoặc sử dụng:

**NextDNS DoH (DNS over HTTPS)**: `https://dns.nextdns.io/YOUR_PROFILE_ID`  
**NextDNS DoT (DNS over TLS)**: `dns.nextdns.io`

### Router

1. Truy cập trang quản lý Router
2. Vào **Network Settings** → **DNS**
3. Thay đổi DNS Primary và Secondary thành:
   - Primary: `45.90.28.0`
   - Secondary: `45.90.30.0`
4. Lưu thay đổi

### Windows

```powershell
# Mở PowerShell as Administrator
Set-DnsClientServerAddress -InterfaceIndex (Get-NetAdapter | Where-Object {$_.Status -eq "Up"}).InterfaceIndex -ServerAddresses ("45.90.28.0", "45.90.30.0")
```

### macOS

```bash
# Cấu hình DNS qua Terminal
sudo networksetup -setdnsservers Wi-Fi 45.90.28.0 45.90.30.0
sudo networksetup -setdnsservers Ethernet 45.90.28.0 45.90.30.0
```

### Linux

**Sử dụng systemd-resolved:**

```bash
# Chỉnh sửa file
sudo nano /etc/systemd/resolved.conf

# Thêm dòng này:
DNS=45.90.28.0 45.90.30.0
FallbackDNS=45.90.30.0

# Khởi động lại
sudo systemctl restart systemd-resolved
```

### Android

1. Mở **Settings** → **Network & Internet** → **Advanced** → **Private DNS**
2. Chọn **Private DNS provider hostname**
3. Nhập: `dns.nextdns.io` hoặc `YOUR_PROFILE_ID.dns.nextdns.io`
4. Lưu

### iOS

1. Mở **Settings** → **Wi-Fi**
2. Chọn network, tap vào ⓘ
3. Chọn **Configure DNS**
4. Chọn **Manual**
5. Nhập DNS servers:
   - Primary: `45.90.28.0`
   - Secondary: `45.90.30.0`

## Troubleshooting

### Free Fire vẫn kết nối được

- ☐ Kiểm tra Profile ID có đúng không
- ☐ Kiểm tra DNS trên thiết bị đã thay đổi chưa
- ☐ Xóa cache DNS: `sudo systemctl restart systemd-resolved`
- ☐ Khởi động lại router
- ☐ Xóa app Free Fire cache

### NextDNS không hoạt động

```bash
# Kiểm tra NextDNS daemon
sudo systemctl status nextdns

# Restart NextDNS
sudo systemctl restart nextdns

# Xem logs
sudo journalctl -u nextdns -f
```

### Không thể kết nối Internet

- Kiểm tra DNS fallback đã được cấu hình
- Thử sử dụng Google DNS tạm thời: `8.8.8.8, 8.8.4.4`
- Kiểm tra lại NextDNS IP có chính xác

## Cập nhật Blocklist

```bash
# Tải bản cập nhật mới
git pull origin main

# Cập nhật danh sách trên NextDNS
# Truy cập https://my.nextdns.io/ và cập nhật thủ công
```

## Gỡ cài đặt

```bash
# Dừng NextDNS
sudo nextdns stop

# Gỡ cài đặt
sudo nextdns uninstall

# Khôi phục DNS mặc định
# Đặt lại DNS thành:
# - 8.8.8.8, 8.8.4.4 (Google)
# - 1.1.1.1, 1.0.0.1 (Cloudflare)
```

## Tham khảo thêm

- [NextDNS Documentation](https://nextdns.io/docs)
- [NextDNS CLI](https://github.com/nextdns/nextdns)
- [DNS over HTTPS](https://en.wikipedia.org/wiki/DNS_over_HTTPS)

---

**Cần giúp đỡ?** Tạo Issue trên [GitHub](https://github.com/huyquoc29098-cyber/nextdns-ff-blocker/issues)

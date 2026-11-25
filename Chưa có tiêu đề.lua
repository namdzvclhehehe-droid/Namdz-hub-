local HubName = "namdz Hub"


-------------------------------------------------------------------------------
-- Lớp tương thích Arceus X (đã thêm). Bổ sung các chức năng thực thi còn thiếu.
-- với các phương án dự phòng an toàn để phần còn lại của kịch bản không bao giờ gặp lỗi.
-------------------------------------------------------------------------------
pcall(function()
    cục bộ G = (type(getgenv) == "function" và getgenv()) hoặc getfenv(0)
    hàm cục bộ def(name, value)
        nếu G[name] == nil và value ~= nil thì
            G[tên] = giá trị
        kết thúc
    kết thúc


    -- Yêu cầu HTTP: Arceus X thường hiển thị yêu cầu / http_request
    def("request", http_request or (syn and syn.request) or (fluxus and fluxus.request) or (http and http.request))
    def("http_request", request)


    -- Clipboard
    def("setclipboard", toclipboard or (Clipboard and Clipboard.set) or set_clipboard)


    -- Hàng đợi khi dịch chuyển tức thời (kịch bản đã xử lý trường hợp này là nil)
    def("queue_on_teleport", queueonteleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport))


    -- Phương án dự phòng firesignal được xây dựng trên getconnections
    nếu G.firesignal == nil và kiểu (getconnections) == "function" thì
        G.firesignal = function(signal, ...)
            for _, conn in ipairs(getconnections(signal)) do
                nếu conn.Fire thì
                    conn:Fire(...)
                nếu conn.Function thì
                    task.spawn(conn.Function, ...)
                kết thúc
            kết thúc
        kết thúc
    kết thúc


    -- fireproximityprompt fallback
    nếu G.fireproximityprompt == nil thì
        G.fireproximityprompt = function(prompt)
            nếu prompt và prompt:IsA("ProximityPrompt") thì
                lời nhắc:InputHoldBegin()
                task.wait((prompt.HoldDuration or 0) + 0.05)
                nhắc nhở:InputHoldEnd()
            kết thúc
        kết thúc
    kết thúc


    -- Thông báo cho người dùng biết trình thực thi/tính năng nào đã được phát hiện
    tên cục bộ = (type(identifyexecutor) == "function" và select(1, identifyexecutor())) hoặc "Không xác định"
    print(("[namdz] Executor: %s | file=%s | getconnections=%s | request=%s"):format(
        tostring(name),
        tostring(type(writefile) == "function"),
        tostring(type(getconnections) == "function"),
        tostring(type(G.request) == "function")
    ))
hết)


-------------------------------------------------------------------------------
-- 👇 MÃ CODE CHÍNH CỦA BẠN BẮT ĐẦU TẠI ĐÂY 👇
-------------------------------------------------------------------------------


print(HubName .. " Tải thành công!")




-------------------------------------------------------------------------------
-- namdz UI: một thư viện giao diện người dùng nhỏ gọn, mượt mà và không phụ thuộc vào bất kỳ thư viện nào khác.
-- Cùng một API Thư viện/Cửa sổ/Tab mà phần còn lại của kịch bản này đã sử dụng.
-- Màu sắc nằm trong thư viện Library.Theme bên dưới.
-------------------------------------------------------------------------------
Thư viện cục bộ = (hàm()
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")


Thư viện cục bộ = {}
Library.Flags = {}


-- Hỗ trợ ngôn ngữ giao diện người dùng thời gian chạy. Các giá trị nội bộ của trò chơi (Chế độ Thường/Ác mộng, ID vật phẩm,
-- các lập luận từ xa, v.v.) cố ý không được dịch.
Library.Language = "Tiếng Việt"
Library._TextObjects = setmetatable({}, { __mode = "k" })
bản dịch tiếng Anh cục bộ = {
    ["namdz Hub"] = "namdz Hub", ["Trang chủ"] = "Nhà", ["Chính"] = "Chính",
    ["Dịch chuyển"] = "Dịch chuyển", ["Cửa hàng"] = "Shop", ["Nâng cấp"] = "Nâng cấp",
    ["Khác"] = "Khác", ["Cài đặt"] = "Cài đặt", ["Bán cá"] = "Bán cá",
    ["Tự động bán cá"] = "Bán cá tự động", ["Cách bán cá #1"] = "Phương pháp bán cá số 1",
    ["Nhiệm vụ vé tự động"] = "Nhiệm vụ vé tự động", ["Tự nhận vé nhiệm vụ"] = "Tự động nhận vé nhiệm vụ",
    ["Chế độ nhiệm vụ"] = "Chế độ nhiệm vụ", ["Chung"] = "Chung", ["Di chuyển"] = "Chuyển động",
    ["Tốc độ đi bộ"] = "Tốc độ đi bộ", ["Tốc độ"] = "Tốc độ", ["Tốc độ bay"] = "Tốc độ bay",
    ["Đi xuyên vật thể"] = "Noclip", ["Nhảy vô hạn"] = "Nhảy vô hạn", ["Đảo"] = "Quần đảo",
    ["Chọn đảo"] = "Chọn Đảo", ["Dịch chuyển đến đảo"] = "Dịch chuyển đến Đảo",
    ["NPC"] = "NPC", ["Chọn NPC"] = "Chọn NPC", ["Dịch chuyển đến NPC"] = "Dịch chuyển đến NPC",
    ["Người chơi"] = "Người chơi", ["Chọn người chơi"] = "Chọn người chơi", ["Dịch chuyển đến người chơi"] = "Dịch chuyển đến người chơi",
    ["Cá"] = "Cá", ["Mở khóa tất cả cá"] = "Mở khóa tất cả cá", ["Mua mồi"] = "Mua mồi",
    ["Chọn"] = "Chọn mồi", ["Số lượng mua"] = "Số tiền mua", ["Độ im mua (phút)"] = "Độ trễ mua hàng (phút)",
    ["Tự động mua mồi"] = "Auto Buy Bait", ["Chế độ tạo mục tiêu"] = "Craft Bait", ["Số lượng chế tạo"] = "Số lượng thủ công",
    ["Tự động tạo mục tiêu"] = "Auto Craft Bait", ["Chế độ tạo cần câu"] = "Craft Rod",
    ["Chọn cần câu"] = "Chọn Cần câu", ["Tự động tạo cần câu"] = "Auto Craft Rod",
    ["ESP người chơi"] = "Người chơi ESP", ["Nâng cấp nhân vật"] = "Nâng cấp nhân vật",
    ["Chọn 2 cấp nâng cấp"] = "Chọn 2 Chỉ số nâng cấp", ["Phương thức nâng cấp"] = "Phương thức nâng cấp",
    ["Tự động tái sinh"] = "Tự động tái sinh", ["Kiểm tra tài nguyên"] = "Kiểm tra tài nguyên",
    ["Hiển thị"] = "Hình ảnh", ["Chống AFK"] = "Chống AFK", ["Chống quản trị viên"] = "Chống quản trị viên",
    ["Tăng sáng tối đa"] = "Đầy đủ sáng", ["Tắt sương mù"] = "Tắt sương mù", ["Chế độ hiệu năng"] = "Chế độ hiệu suất",
    ["Bật thông báo"] = "Bật thông báo", ["Thông báo"] = "Thông báo", ["Đã bật thông báo"] = "Đã bật thông báo",
    ["Câu cá"] = "Câu cá", ["Khóa thanh bắt cá"] = "Khóa thanh bắt cá", ["Tự động thả câu"] = "Auto Cast",
    ["Tự động câu cá Boss"] = "Trùm bí mật trang trại tự động", ["Tự động câu cá Boss bí mật"] = "Trùm bí mật trang trại tự động",
    ["Cách thả câu"] = "Phương pháp thi triển", ["Độ đĩnh thả câu"] = "Độ trễ thi triển", ["Tự trang bị mồi ngon nhất"] = "Auto Trang bị mồi tốt nhất",
    ["Tự trang thiết bị cần câu"] = "Thanh trang bị tự động", ["Kỹ năng"] = "Kỹ năng", ["Tự động sử dụng kỹ năng"] = "Kỹ năng sử dụng tự động",
    ["Chọn kỹ năng"] = "Chọn kỹ năng", ["Boss"] = "Sếp", ["Chọn chế độ Boss"] = "Chọn chế độ Boss",
    ["Tự động Enzo"] = "Tự động Enzo", ["Tự động Long DiaoHai"] = "Tự động Long DiaoHai",
    ["Tự động chơi mini game"] = "Tự động chơi Minigame", ["Vị trí"] = "Vị trí", ["Lưu vị trí"] = "Lưu vị trí",
    ["Đã lưu vị trí!"] = "Đã lưu vị trí!", ["Tự dịch chuyển đến vị trí"] = "Tự động dịch chuyển đến vị trí",
    ["Xóa vị trí"] = "Xóa vị trí", ["Đã xóa vị trí!"] = "Đã xóa vị trí!",
    ["Mã quà tặng"] = "Mã quà tặng", ["Nhập tất cả mã"] = "Đổi tất cả mã", ["Menu tiện ích"] = "Menu tiện ích",
    ["Mở nâng cấp kỹ năng"] = "Nâng cấp kỹ năng mở", ["Mở học kỹ năng"] = "Học kỹ năng mở",
    ["Mở giao diện trao đổi"] = "Giao diện người dùng mở", ["Mở đặc tính"] = "Mở đặc điểm", ["Phím tắt"] = "Hotkey",
    ["Tắt phím tắt"] = "Tắt phím tắt", ["Phím bật bay"] = "Fly Toggle Key", ["Phím bật xuyên vật thể"] = "Noclip Toggle Key",
    ["Máy chủ"] = "Máy chủ", ["Vào lại máy chủ"] = "Tham gia lại máy chủ", ["Đổi máy chủ ít người"] = "Tham gia máy chủ có dân số thấp",
    ["Tự đăng lại"] = "Tự động tham gia lại", ["Tự đăng lại khi mất kết nối"] = "Tự động tham gia lại khi ngắt kết nối",
    ["Thông báo Discord Webhook"] = "Thông báo Webhook Discord", ["Thông báo qua Webhook"] = "Thông báo Webhook",
    ["Đường dẫn Webhook"] = "URL Webhook", ["Gửi thử Webhook"] = "Kiểm tra Webhook", ["Quyền riêng tư"] = "Quyền riêng tư",
    ["Ẩn ID của tôi (góc trên phải)"] = "Ẩn ID của tôi (trên cùng bên phải)", ["ID giả"] = "ID giả",
    ["Số ID giả"] = "Số ID giả", ["Ẩn tên"] = "Ẩn tên", ["Tên giả"] = "Tên giả",
    ["Nội dung tên giả"] = "Văn bản tên giả", ["Ngôn ngữ / Ngôn ngữ"] = "Ngôn ngữ / Ngôn ngữ",
    ["Tiếng Việt"] = "Tiếng Việt", ["Tiếng Anh"] = "Tiếng Anh", ["Không có"] = "Không có", ["Không có"] = "Không có",
    ["Bật"] = "Đã bật", ["Tắt"] = "Đã tắt", ["Đang tải..."] = "Đang tải...",
    ["Tìm máy chủ ít người..."] = "Đang tìm kiếm máy chủ có dân số thấp...",
    ["Đang tự động kết nối lại..."] = "Đang kết nối lại tự động...",
    ["Đã lưu URL Webhook."] = "Đã lưu URL Webhook.", ["Đây không phải liên kết Discord Webhook."] = "Đây không phải là URL Webhook của Discord.",
}
hàm cục bộ translateText(value)
    if type(value) ~= "string" then return value end


    -- Cũng xây dựng chức năng tra cứu ngược, để có thể tạo nhãn bằng tiếng Anh/cập nhật động.
    -- luôn có thể quay lại tiếng Việt khi người dùng chuyển đổi lại ngôn ngữ.
    local REVERSE_TRANSLATIONS = Library._ReverseTranslations
    nếu không phải là REVERSE_TRANSLATIONS thì
        DỊCH ĐẢO NGƯỢC = {}
        đối với vi, en theo cặp(EN_TRANSLATIONS) do
            nếu REVERSE_TRANSLATIONS[en] == nil thì
                DỊCH NGƯỢC[en] = vi
            kết thúc
        kết thúc
        Library._ReverseTranslations = REVERSE_TRANSLATIONS
    kết thúc


    bản đồ cục bộ = (Library.Language == "English") và EN_TRANSLATIONS hoặc REVERSE_TRANSLATIONS
    cục bộ chính xác = map[giá trị]
    nếu chính xác thì trả về kết thúc chính xác


    local upper = string.upper(value)
    for source, target in pairs(map) do
        nếu chuỗi viết hoa (nguồn) == viết hoa thì
            trả về chuỗi.chữ hoa(mục tiêu)
        kết thúc
    kết thúc
    Giá trị trả về
kết thúc
Hàm Library:SetLanguage(language)
    self.Language = (language == "English") and "English" or "Tiếng Việt"
    for obj, record in pairs(self._TextObjects) do
        nếu obj và obj.Parent thì
            record.updating = true
            obj.Text = translateText(record.source)
            -- Hoãn việc thiết lập lại bộ bảo vệ cho đến khi Roblox gửi tín hiệu thay đổi thuộc tính.
            task.defer(function()
                record.updating = false
            hết)
        khác
            self._TextObjects[obj] = nil
        kết thúc
    kết thúc
kết thúc


Chủ đề cục bộ = {
    Nền = Color3.fromRGB(6, 8, 20),
    Thanh trên cùng = Color3.fromRGB(10, 13, 30),
    Thanh bên = Color3.fromRGB(8, 10, 25),
    Bề mặt = Color3.fromRGB(13, 17, 38),
    Surface2 = Color3.fromRGB(21, 27, 60),
    Surface3 = Color3.fromRGB(32, 40, 86),
    Stroke = Color3.fromRGB(48, 60, 120),
    Accent = Color3.fromRGB(0, 235, 255), -- Cyan #00EBFF
    AccentText = Color3.fromRGB(4, 8, 20),
    Văn bản = Color3.fromRGB(230, 240, 255),
    Muted = Color3.fromRGB(150, 165, 210),
    Lỗi = Color3.fromRGB(255, 95, 125),
    Cảnh báo = Color3.fromRGB(255, 196, 92),
    Thành công = Color3.fromRGB(70, 255, 190),
    Cyan = Color3.fromRGB(0, 235, 255), -- #00EBFF
    Màu tím = Color3.fromRGB(130, 95, 255), -- #825FFF
}
Library.Theme = Theme

-- các tấm panel trong suốt như thế nào, nên phông nền dạng lưới phía sau hiện ra mờ ảo.
local PANEL_ALPHA = 0.22
local BAR_ALPHA = 0.12
local ACCENT_SEQUENCE = ColorSequence.new(Theme.Cyan, Theme.Purple)


local FONT = Enum.Font.GothamMedium
local FONT_BOLD = Enum.Font.GothamBold


---------------------------------------------------------------- trợ giúp
hàm cục bộ tween(obj, time, props, style, dir)
    local t = TweenService:Create(
        obj,
        TweenInfo.new(time, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out),
        thuộc tính
    )
    t:Play()
    trả về t
kết thúc


hàm cục bộ mới (lớp, thuộc tính, cha)
    local inst = Instance.new(class)
    for key, value in pairs(props or {}) do
        inst[key] = giá trị
    kết thúc
    nếu class == "TextLabel" hoặc class == "TextButton" hoặc class == "TextBox" thì
        bản ghi cục bộ = { nguồn = tostring(inst.Text hoặc ""), cập nhật = false }
        Library._TextObjects[inst] = bản ghi
        record.updating = true
        inst.Text = translateText(record.source)
        task.defer(function()
            record.updating = false
        hết)
        inst:GetPropertyChangedSignal("Text"):Connect(function()
            nếu bản ghi đang được cập nhật thì trả về kết thúc
            record.source = tostring(inst.Text or "")
            local translated = translateText(record.source)
            nếu translated ~= inst.Text thì
                record.updating = true
                inst.Text = đã dịch
                record.updating = false
            kết thúc
        hết)
    kết thúc
    nếu là phần tử cha thì
        inst.Parent = cha
    kết thúc
    trả về inst
kết thúc


hàm cục bộ round(parent, radius)
    return new("UICorner", { CornerRadius = UDim.new(0, radius) }, parent)
kết thúc


đường viền hàm cục bộ(cha, màu sắc, độ dày, độ trong suốt)
    trả về new("UIStroke", {
        Màu sắc = màu hoặc Theme.Stoke,
        Độ dày = độ dày hoặc 1,
        Độ minh bạch = độ minh bạch hoặc 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, phần tử cha)
kết thúc


gradient hàm cục bộ (cha, xoay)
    return new("UIGradient", { Color = ACCENT_SEQUENCE, Rotation = rotation or 0 }, parent)
kết thúc


hàm cục bộ pad(parent, left, top, right, bottom)
    trả về new("UIPadding", {
        PaddingLeft = UDim.new(0, left),
        PaddingTop = UDim.new(0, top),
        PaddingRight = UDim.new(0, right),
        PaddingBottom = UDim.new(0, bottom),
    }, phần tử cha)
kết thúc


hàm cục bộ văn bản(parent, props)
    cơ sở cục bộ = {
        Độ trong suốt nền = 1,
        BorderSizePixel = 0,
        Phông chữ = FONT,
        Kích thước văn bản = 13,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Văn bản = "",
        TextStrokeColor3 = Color3.new(0, 0, 0),
        Độ trong suốt của nét chữ = 0.45,
    }
    for key, value in pairs(props) do
        base[key] = giá trị
    kết thúc
    return new("TextLabel", base, parent)
kết thúc


hàm cục bộ hitbox(parent, size)
    trả về new("TextButton", {
        Kích thước = kích thước hoặc UDim2.fromScale(1, 1),
        Độ trong suốt nền = 1,
        Văn bản = "",
        AutoButtonColor = false,
        ZIndex = 3,
    }, phần tử cha)
kết thúc


hàm cục bộ safe(fn, ...)
    nếu kiểu(fn) ~= "function" thì
        trả về
    kết thúc
    cục bộ ok, err = pcall(fn, ...)
    nếu không ổn thì
        cảnh báo("[namdz Hub] lỗi gọi lại: " .. tostring(err))
    kết thúc
kết thúc


hàm cục bộ opt(source)
    nếu kiểu dữ liệu (nguồn) == "string" thì
        trả về { Tên = nguồn }
    kết thúc
    return type(source) == "table" and source or {}
kết thúc


hàm cục bộ titleOf(o)
    return tostring(o.Name or o.Title or o.Text or "")
kết thúc


hàm cục bộ descOf(o)
    local d = o.Description or o.Desc
    trả về d ~= nil và tostring(d) hoặc ""
kết thúc


thanh ghi hàm cục bộ(o, phần tử)
    nếu o.Flag thì
        Library.Flags[o.Flag] = phần tử
    kết thúc
    trả về phần tử
kết thúc


hàm cục bộ isPointer(input)
    trả về input.UserInputType == Enum.UserInputType.MouseButton1
        hoặc input.UserInputType == Enum.UserInputType.Touch
kết thúc


hàm cục bộ isMove(input)
    return input.UserInputType == Enum.UserInputType.MouseMovement
        hoặc input.UserInputType == Enum.UserInputType.Touch
kết thúc


hàm cục bộ attachHover(frame, button)
    button.MouseEnter:Connect(function()
        tween(frame, 0.15, { BackgroundColor3 = Theme.Surface2 })
    hết)
    button.MouseLeave:Connect(function()
        tween(frame, 0.2, { BackgroundColor3 = Theme.Surface })
    hết)
kết thúc


hàm cục bộ chứa(danh sách, giá trị)
    for _, v in ipairs(list) do
        nếu v == giá trị thì
            Trả về true
        kết thúc
    kết thúc
    Trả về false
kết thúc


hàm cục bộ keyFrom(value)
    nếu kiểu dữ liệu của giá trị là "EnumItem" thì
        Giá trị trả về
    kết thúc
    cục bộ ổn, đã tìm thấy = pcall(function()
        trả về Enum.KeyCode[tostring(value)]
    hết)
    trả về (ok và đã tìm thấy) hoặc Enum.KeyCode.Unknown
kết thúc


---------------------------------------------------------------- gui root
giao diện người dùng cục bộ


hàm cục bộ getGui()
    nếu gui và gui.Parent thì
        trả về giao diện người dùng
    kết thúc
    gui = new("ScreenGui", {
        Tên = "namdzHubUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 9999,
        IgnoreGuiInset = true,
    })
    pcall(function()
        gui.Parent = (type(gethui) == "function" and gethui()) or CoreGui
    hết)
    nếu không phải gui.Parent thì
        gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    kết thúc


    người giữ cục bộ = mới("Khung", {
        Tên = "Thông báo",
        AnchorPoint = Vector2.new(1, 0),
        Vị trí = UDim2.new(1, -14, 0, 14),
        Kích thước = UDim2.fromOffset(270, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Độ trong suốt nền = 1,
    }, gui)
    new("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
    }, holder)
    trả về giao diện người dùng
kết thúc


Hàm Library:Notify(o)
    nếu Library.NotificationsEnabled == false thì
        trả về
    kết thúc
    o = opt(o)
    local holder = getGui():FindFirstChild("Notifications")
    nếu không phải là người nắm giữ thì
        trả về
    kết thúc
    local kind = string.lower(tostring(o.Type or ""))
    màu cục bộ = Theme.Text
    nếu loại == "lỗi" thì
        màu = Theme.Error
    ngược lại nếu kind == "warning" thì
        màu = Theme.Warning
    nếu kind == "success" thì
        màu = Theme.Success
    kết thúc


    bao bọc cục bộ = mới("Khung", {
        Kích thước = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Độ trong suốt nền = 1,
    }, holder)
    thẻ cục bộ = mới("Khung", {
        Kích thước = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Vị trí = UDim2.new(1.2, 0, 0, 0),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
    }, wrap)
    round(card, 10)
    gradient(outline(card, Color3.new(1, 1, 1), 1.2, 0.15), 45)
    pad(card, 14, 10, 12, 10)
    new("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }, card)


    văn bản(thẻ, {
        Kích thước = UDim2.new(1, 0, 0, 16),
        Phông chữ = FONT_BOLD,
        Kích thước văn bản = 13,
        TextColor3 = màu,
        Văn bản = tostring(o.Title hoặc "namdz Hub"),
        LayoutOrder = 1,
    })
    nội dung cục bộ = tostring(o.Content hoặc o.Text hoặc "")
    nếu nội dung ~= "" thì
        văn bản(thẻ, {
            Kích thước = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Kích thước văn bản = 12,
            TextColor3 = Theme.Muted,
            TextWrapped = true,
            TextYAlignment = Enum.TextYAlignment.Top,
            Văn bản = nội dung,
            LayoutOrder = 2,
        })
    kết thúc


    tween(card, 0.4, { Position = UDim2.new(0, 0, 0, 0) })
    task.delay(tonumber(o.Duration) or 4, function()
        nếu thẻ.Cha thì
            tween(card, 0.3, { Position = UDim2.new(1.2, 0, 0, 0) }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
            task.delay(0.35, function()
                wrap:Destroy()
            hết)
        kết thúc
    hết)
kết thúc


---------------------------------------------------------------- tab / các phần tử
Tab cục bộ = {}
Tab.__index = Tab


hàm Tab:_add(frame)
    self._n = self._n + 1
    frame.LayoutOrder = self._n
    frame.Parent = self.Page
    khung trả về
kết thúc


hàm Tab:_row(chiều cao)
    cục bộ f = mới("Khung", {
        Kích thước = UDim2.new(1, 0, 0, chiều cao),
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = PANEL_ALPHA,
        BorderSizePixel = 0,
    })
    round(f, 8)
    outline(f, Theme.Stroke, 1, 0.4)
    trả về self:_add(f)
kết thúc


Hàm Tab:CreateSection(tên)
    cục bộ o = opt(name)
    người giữ cục bộ = mới("Khung", {
        Kích thước = UDim2.new(1, 0, 0, 26),
        Độ trong suốt nền = 1,
    })
    văn bản(khung, {
        Kích thước = UDim2.new(1, -4, 1, -2),
        Vị trí = UDim2.new(0, 4, 0, 4),
        Phông chữ = FONT_BOLD,
        Kích thước văn bản = 11,
        TextColor3 = Theme.Muted,
        TextYAlignment = Enum.TextYAlignment.Bottom,
        Văn bản = chuỗi.chữ hoa(titleOf(o)),
    })
    self:_add(holder)
kết thúc


hàm Tab:CreateParagraph(o)
    o = opt(o)
    cục bộ f = mới("Khung", {
        Kích thước = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = PANEL_ALPHA,
        BorderSizePixel = 0,
    })
    round(f, 8)
    outline(f, Theme.Stroke, 1, 0.4)
    pad(f, 14, 10, 14, 10)
    new("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }, f)
    local title = tostring(o.Title or o.Name or "")
    nếu tiêu đề ~= "" thì
        văn bản(f, {
            Kích thước = UDim2.new(1, 0, 0, 16),
            Phông chữ = FONT_BOLD,
            Văn bản = tiêu đề,
            LayoutOrder = 1,
        })
    kết thúc
    nội dung cục bộ = tostring(o.Content hoặc o.Text hoặc descOf(o))
    nếu nội dung ~= "" thì
        văn bản(f, {
            Kích thước = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Kích thước văn bản = 12,
            TextColor3 = Theme.Muted,
            TextWrapped = true,
            TextYAlignment = Enum.TextYAlignment.Top,
            Văn bản = nội dung,
            LayoutOrder = 2,
        })
    kết thúc
    self:_add(f)
    trả về thanh ghi (o, {})
kết thúc
Tab.CreateLabel = Tab.CreateParagraph


hàm Tab:CreateStatGrid(o)
    o = opt(o)
    các mục cục bộ = o.Items hoặc {}
    cột cục bộ = math.max(1, tonumber(o.Columns) hoặc 3)
    lưới cục bộ = mới("Khung", {
        Kích thước = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Độ trong suốt nền = 1,
    })
    new("UIGridLayout", {
        CellSize = UDim2.new(1 / columns, -math.ceil(8 * (columns - 1) / columns), 0, 62),
        CellPadding = UDim2.fromOffset(8, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, lưới)


    local valueLabels = {}
    for index, item in ipairs(items) do
        thẻ cục bộ = mới("Khung", {
            BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = PANEL_ALPHA,
            BorderSizePixel = 0,
            LayoutOrder = index,
        }, lưới)
        round(card, 10)
        outline(card, Theme.Stroke, 1, 0.4)
        thanh cục bộ = mới("Khung", {
            Vị trí = UDim2.new(0, 12, 0, 10),
            Kích thước = UDim2.fromOffset(18, 2),
            BackgroundColor3 = item.Color hoặc Theme.Accent,
            BorderSizePixel = 0,
        }, thẻ)
        round(bar, 1)
        valueLabels[item.Key] = text(card, {
            Vị trí = UDim2.new(0, 12, 0, 18),
            Kích thước = UDim2.new(1, -24, 0, 22),
            Phông chữ = FONT_BOLD,
            Kích thước văn bản = 15,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Văn bản = tostring(item.Value hoặc "-"),
        })
        văn bản(thẻ, {
            Vị trí = UDim2.new(0, 12, 0, 40),
            Kích thước = UDim2.new(1, -24, 0, 14),
            Kích thước văn bản = 10,
            TextColor3 = Theme.Muted,
            Văn bản = chuỗi chữ hoa (chuyển đổi thành chuỗi ký tự (mục.Nhãn hoặc mục.Khóa)),
        })
    kết thúc
    self:_add(grid)


    cục bộ el = {}
    hàm el:Set(key, value)
        nhãn cục bộ = nhãn giá trị[khóa]
        nếu nhãn thì
            local s = tostring(value)
            nếu label.Text ~= s thì
                label.Text = s
            kết thúc
        kết thúc
    kết thúc
    trả về thanh ghi (o, el)
kết thúc


hàm Tab:CreateButton(o)
    o = opt(o)
    mô tả cục bộ = mô tả của o
    local f = self:_row(desc ~= "" and 52 or 40)
    văn bản(f, {
        Kích thước = UDim2.new(1, -50, 0, desc ~= "" và 18 hoặc 40),
        Vị trí = UDim2.new(0, 14, 0, desc ~= "" và 8 hoặc 0),
        Văn bản = tiêu đề của (o),
    })
    nếu desc ~= "" thì
        văn bản(f, {
            Kích thước = UDim2.new(1, -50, 0, 16),
            Vị trí = UDim2.new(0, 14, 0, 27),
            Kích thước văn bản = 11,
            TextColor3 = Theme.Muted,
            Văn bản = mô tả,
        })
    kết thúc
    văn bản(f, {
        AnchorPoint = Vector2.new(1, 0.5),
        Vị trí = UDim2.new(1, -14, 0.5, 0),
        Kích thước = UDim2.fromOffset(14, 20),
        Phông chữ = FONT_BOLD,
        Kích thước văn bản = 16,
        TextColor3 = Theme.Muted,
        TextXAlignment = Enum.TextXAlignment.Center,
        Văn bản ">",
    })
    va chạm cục bộ = hộp va chạm(f)
    attachHover(f, hit)
    hit.MouseButton1Down:Connect(function()
        tween(f, 0.08, { BackgroundColor3 = Theme.Surface3 })
    hết)
    nhấn.MouseButton1Up:Kết nối(function()
        tween(f, 0.2, { BackgroundColor3 = Theme.Surface2 })
    hết)
    hit.MouseButton1Click:Connect(function()
        safe(o.Callback)
    hết)
    trả về thanh ghi (o, {})
kết thúc


hàm Tab:CreateToggle(o)
    o = opt(o)
    mô tả cục bộ = mô tả của o
    local f = self:_row(desc ~= "" and 52 or 42)
    văn bản(f, {
        Kích thước = UDim2.new(1, -80, 0, desc ~= "" và 18 hoặc 42),
        Vị trí = UDim2.new(0, 14, 0, desc ~= "" và 8 hoặc 0),
        Văn bản = tiêu đề của (o),
    })
    nếu desc ~= "" thì
        văn bản(f, {
            Kích thước = UDim2.new(1, -80, 0, 16),
            Vị trí = UDim2.new(0, 14, 0, 27),
            Kích thước văn bản = 11,
            TextColor3 = Theme.Muted,
            Văn bản = mô tả,
        })
    kết thúc
    viên thuốc cục bộ = mới("Khung", {
        AnchorPoint = Vector2.new(1, 0.5),
        Vị trí = UDim2.new(1, -14, 0.5, 0),
        Kích thước = UDim2.fromOffset(40, 22),
        BackgroundColor3 = Theme.Surface3,
        BorderSizePixel = 0,
    }, f)
    tròn (viên thuốc, 11)
    local pillGlow = new("Frame", {
        Kích thước = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(1, 1, 1),
        Độ trong suốt nền = 1,
        BorderSizePixel = 0,
    }, viên thuốc)
    round(pillGlow, 11)
    gradient(pillGlow, 0)
    nút cục bộ = mới("Khung", {
        Vị trí = UDim2.new(0, 3, 0.5, -8),
        Kích thước = UDim2.fromOffset(16, 16),
        BackgroundColor3 = Theme.Muted,
        BorderSizePixel = 0,
    }, viên thuốc)
    round(knob, 8)


    local default = (o.CurrentValue or o.Default or o.Value) == true
    trạng thái cục bộ = mặc định


    hàm cục bộ paint(instant)
        local pillColor = state and Theme.Accent or Theme.Surface3
        local knobColor = state and Color3.new(1, 1, 1) or Theme.Muted
        local knobPos = state and UDim2.new(0, 21, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        nếu tức thì thì
            pill.BackgroundColor3 = pillColor
            pillGlow.BackgroundTransparency = state và 0 hoặc 1
            knob.BackgroundColor3 = knobColor
            knob.Position = knobPos
        khác
            tween(pill, 0.2, { BackgroundColor3 = pillColor })
            tween(pillGlow, 0.2, { BackgroundTransparency = state and 0 or 1 })
            tween(knob, 0.2, { BackgroundColor3 = knobColor, Position = knobPos })
        kết thúc
    kết thúc


    tập hợp hàm cục bộ (giá trị, yên tĩnh)
        giá trị = giá trị == đúng
        nếu giá trị == trạng thái thì
            trả về
        kết thúc
        trạng thái = giá trị
        vẽ(sai)
        nếu không yên tĩnh thì
            safe(o.Callback, value)
        kết thúc
    kết thúc


    va chạm cục bộ = hộp va chạm(f)
    attachHover(f, hit)
    hit.MouseButton1Click:Connect(function()
        set(not state)
    hết)
    vẽ(đúng)


    cục bộ el = {}
    hàm el:Get()
        trả về trạng thái
    kết thúc
    hàm el:Set(value, quiet)
        set(value, quiet)
    kết thúc
    đăng ký(o, el)
    nếu mặc định thì
        safe(o.Callback, true)
    kết thúc
    trả về phần tử
kết thúc


hàm Tab:CreateSlider(o)
    o = opt(o)
    local min = o.Min or (o.Range and o.Range[1]) or 0
    giá trị cực đại cục bộ = o.Max hoặc (o.Range và o.Range[2]) hoặc 100
    local inc = o.Increment hoặc o.Step hoặc 1
    local frac = tostring(inc):match("%.(%d+)")
    số thập phân cục bộ = frac và #frac hoặc 0
    hậu tố cục bộ = tostring(o.Suffix hoặc o.Unit hoặc "")
    trạng thái cục bộ = math.clamp(tonumber(o.CurrentValue hoặc o.Default hoặc o.Value) hoặc min, min, max)


    cục bộ f = self:_row(56)
    văn bản(f, {
        Kích thước = UDim2.new(1, -110, 0, 18),
        Vị trí = UDim2.new(0, 14, 0, 8),
        Văn bản = tiêu đề của (o),
    })
    nhãn giá trị cục bộ = văn bản(f, {
        AnchorPoint = Vector2.new(1, 0),
        Kích thước = UDim2.fromOffset(90, 18),
        Vị trí = UDim2.new(1, -14, 0, 8),
        Kích thước văn bản = 12,
        TextColor3 = Theme.Muted,
        TextXAlignment = Enum.TextXAlignment.Right,
    })
    theo dõi cục bộ = mới("Khung", {
        Vị trí = UDim2.new(0, 14, 0, 36),
        Kích thước = UDim2.new(1, -28, 0, 6),
        BackgroundColor3 = Theme.Surface3,
        BorderSizePixel = 0,
    }, f)
    round(track, 3)
    local fill = new("Frame", {
        Kích thước = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
    }, track)
    round(fill, 3)
    fill.BackgroundColor3 = Color3.new(1, 1, 1)
    gradient(fill, 0)
    nút cục bộ = mới("Khung", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Vị trí = UDim2.new(1, 0, 0.5, 0),
        Kích thước = UDim2.fromOffset(12, 12),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
    }, điền)
    round(knob, 6)


    hàm cục bộ fmt(value)
        local s = string.format("%." .. decimals .. "f", value)
        trả về hậu tố ~= "" và (s .. " " .. hậu tố) hoặc s
    kết thúc


    hàm cục bộ ratio(value)
        nếu giá trị lớn nhất bằng giá trị nhỏ nhất thì
            Trả về 0
        kết thúc
        Trả về (giá trị - min) / (giá trị lớn nhất - min)
    kết thúc


    hàm cục bộ paint(animate)
        valueLabel.Text = fmt(state)
        kích thước cục bộ = UDim2.new(tỷ lệ(trạng thái), 0, 1, 0)
        nếu hoạt ảnh thì
            tween(fill, 0.15, { Size = size })
        khác
            fill.Size = size
        kết thúc
    kết thúc


    hàm cục bộ apply(value, animate, quiet)
        giá trị = math.clamp(math.floor(giá trị / inc + 0.5) * inc, min, max)
        nếu giá trị == trạng thái thì
            trả về
        kết thúc
        trạng thái = giá trị
        vẽ (hoạt ảnh)
        nếu không yên tĩnh thì
            safe(o.Callback, value)
        kết thúc
    kết thúc


    kéo cục bộ = sai
    local hit = new("TextButton", {
        Vị trí = UDim2.new(0, 8, 0, 26),
        Kích thước = UDim2.new(1, -16, 0, 26),
        Độ trong suốt nền = 1,
        Văn bản = "",
        AutoButtonColor = false,
        ZIndex = 3,
    }, f)


    hàm cục bộ từ X(x)
        chiều rộng cục bộ = math.max(track.AbsoluteSize.X, 1)
        local p = math.clamp((x - track.AbsolutePosition.X) / width, 0, 1)
        áp dụng(min + (max - min) * p, false)
    kết thúc


    hit.InputBegan:Connect(function(input)
        nếu isPointer(input) thì
            kéo = đúng
            self.Page.ScrollingEnabled = false
            fromX(input.Position.X)
        kết thúc
    hết)
    UserInputService.InputChanged:Connect(function(input)
        nếu kéo và là Di chuyển(đầu vào) thì
            fromX(input.Position.X)
        kết thúc
    hết)
    UserInputService.InputEnded:Connect(function(input)
        nếu kéo và là con trỏ (đầu vào) thì
            kéo = sai
            self.Page.ScrollingEnabled = true
        kết thúc
    hết)
    vẽ(sai)


    cục bộ el = {}
    hàm el:Get()
        trả về trạng thái
    kết thúc
    hàm el:Set(value, quiet)
        áp dụng(tonumber(value) hoặc state, true, quiet)
    kết thúc
    trả về thanh ghi (o, el)
kết thúc


Hàm Tab:_dropdown(o, multi)
    local options = table.clone(o.Options or o.Values ​​or o.Items or {})
    dòng điện cục bộ = o.CurrentOption
    nếu hiện tại == nil thì
        hiện tại = o.Default
    kết thúc


    trạng thái cục bộ
    cục bộ được chọn = {}
    nếu là nhiều thì
        nếu kiểu dữ liệu hiện tại là "bảng" thì
            for _, v in ipairs(current) do
                selected[v] = true
            kết thúc
        kết thúc
    khác
        nếu kiểu dữ liệu hiện tại là "bảng" thì
            hiện tại = hiện tại[1]
        kết thúc
        nếu current == nil hoặc không chứa (tùy chọn, current) thì
            hiện tại = tùy chọn[1]
        kết thúc
        trạng thái = hiện tại
    kết thúc


    cục bộ f = mới("Khung", {
        Kích thước = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = PANEL_ALPHA,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    })
    round(f, 8)
    outline(f, Theme.Stroke, 1, 0.4)
    self:_add(f)


    văn bản(f, {
        Kích thước = UDim2.new(0.5, -14, 0, 42),
        Vị trí = UDim2.new(0, 14, 0, 0),
        Văn bản = tiêu đề của (o),
    })
    nhãn giá trị cục bộ = văn bản(f, {
        Kích thước = UDim2.new(0.5, -44, 0, 42),
        Vị trí = UDim2.new(0.5, 0, 0, 0),
        Kích thước văn bản = 12,
        TextColor3 = Theme.Muted,
        TextXAlignment = Enum.TextXAlignment.Right,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })
    mũi tên cục bộ = văn bản(f, {
        AnchorPoint = Vector2.new(0.5, 0),
        Vị trí = UDim2.new(1, -20, 0, 0),
        Kích thước = UDim2.fromOffset(14, 42),
        Phông chữ = FONT_BOLD,
        Kích thước văn bản = 15,
        TextColor3 = Theme.Muted,
        TextXAlignment = Enum.TextXAlignment.Center,
        Văn bản ">",
    })
    tiêu đề cục bộ = hitbox(f, UDim2.new(1, 0, 0, 42))
    attachHover(f, header)


    danh sách cục bộ = mới("ScrollingFrame", {
        Vị trí = UDim2.new(0, 8, 0, 46),
        Kích thước = UDim2.new(1, -16, 0, 0),
        Độ trong suốt nền = 1,
        BorderSizePixel = 0,
        Độ dày thanh cuộn = 2,
        ScrollBarImageColor3 = Theme.Surface3,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, f)
    new("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }, list)


    cục bộ mở = sai
    nút cục bộ = {}


    hàm cục bộ selectedList()
        kết quả cục bộ = {}
        for _, v in ipairs(options) do
            nếu được chọn[v] thì
                kết quả[#kết quả + 1] = v
            kết thúc
        kết thúc
        trả về kết quả
    kết thúc


    hàm cục bộ listHeight()
        cục bộ n = #tùy chọn
        nếu n == 0 thì
            Trả về 0
        kết thúc
        return math.min(n * 30 + (n - 1) * 2, 150)
    kết thúc


    hàm cục bộ paintHeader()
        nếu là nhiều thì
            local n = #selectedList()
            valueLabel.Text = n > 0 và (n .. " đã chọn") hoặc "Không có"
        khác
            valueLabel.Text = state ~= nil and tostring(state) or "None"
        kết thúc
    kết thúc


    hàm cục bộ paintOptions()
        Đối với tùy chọn, các bộ phận theo cặp (nút)
            cục bộ trên = đa và được chọn[tùy chọn] hoặc (không đa và tùy chọn == trạng thái)
            tween(parts.label, 0.15, { TextColor3 = on and Theme.Text or Theme.Muted })
            tween(parts.button, 0.15, { BackgroundTransparency = (on and not multi) and 0.5 or 1 })
            nếu parts.box thì
                tween(parts.box, 0.15, { BackgroundColor3 = on and Theme.Accent or Theme.Surface3 })
            kết thúc
        kết thúc
    kết thúc


    hàm cục bộ resize()
        chiều cao cục bộ = danh sách chiều cao()
        list.Size = UDim2.new(1, -16, 0, height)
        tween(f, 0.22, { Size = UDim2.new(1, 0, 0, open and (46 + height + 8) or 42) })
        tween(chevron, 0.22, { Rotation = open and 90 or 0 })
    kết thúc


    hàm cục bộ rebuild()
        for _, child in ipairs(list:GetChildren()) do
            nếu phần tử con là một ("TextButton") thì
                child:Destroy()
            kết thúc
        kết thúc
        buttons = {}
        for index, option in ipairs(options) do
            cục bộ b = mới("Nút văn bản", {
                Kích thước = UDim2.new(1, 0, 0, 30),
                BackgroundColor3 = Theme.Surface3,
                Độ trong suốt nền = 1,
                AutoButtonColor = false,
                Văn bản = "",
                LayoutOrder = index,
            }, danh sách)
            round(b, 6)
            nhãn cục bộ = văn bản(b, {
                Kích thước = UDim2.new(1, -40, 1, 0),
                Vị trí = UDim2.new(0, 10, 0, 0),
                Kích thước văn bản = 12,
                TextColor3 = Theme.Muted,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Văn bản = tostring(tùy chọn),
            })
            hộp cục bộ
            nếu là nhiều thì
                hộp = mới("Khung", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Vị trí = UDim2.new(1, -8, 0.5, 0),
                    Kích thước = UDim2.fromOffset(16, 16),
                    BackgroundColor3 = Theme.Surface3,
                    BorderSizePixel = 0,
                }, b)
                round(box, 4)
            kết thúc
            buttons[option] = { button = b, label = label, box = box }
            b.MouseEnter:Connect(function()
                nếu multi hoặc option ~= state thì
                    tween(b, 0.12, { BackgroundTransparency = 0.6 })
                kết thúc
            hết)
            b.MouseLeave:Connect(function())
                cục bộ trên = đa và được chọn[tùy chọn] hoặc (không đa và tùy chọn == trạng thái)
                tween(b, 0.15, { BackgroundTransparency = (on and not multi) and 0.5 or 1 })
            hết)
            b.MouseButton1Click:Connect(function()
                nếu là nhiều thì
                    selected[option] = (not selected[option]) or nil
                    paintHeader()
                    paintOptions()
                    safe(o.Callback, selectedList())
                khác
                    mở = false
                    resize()
                    nếu tùy chọn ~= trạng thái thì
                        trạng thái = tùy chọn
                        paintHeader()
                        paintOptions()
                        safe(o.Callback, option)
                    kết thúc
                kết thúc
            hết)
        kết thúc
        paintOptions()
    kết thúc


    header.MouseButton1Click:Connect(function()
        mở = không mở
        resize()
    hết)


    rebuild()
    paintHeader()


    cục bộ el = {}
    hàm el:Get()
        nếu là nhiều thì
            Trả về danh sách đã chọn()
        kết thúc
        trả về trạng thái
    kết thúc
    hàm el:Set(value, quiet)
        nếu là nhiều thì
            đã chọn = {}
            nếu kiểu dữ liệu (giá trị) == "bảng" thì
                for _, v in ipairs(value) do
                    selected[v] = true
                kết thúc
            kết thúc
            paintHeader()
            paintOptions()
            nếu không yên tĩnh thì
                safe(o.Callback, selectedList())
            kết thúc
        khác
            trạng thái = giá trị
            paintHeader()
            paintOptions()
            nếu không yên tĩnh thì
                safe(o.Callback, value)
            kết thúc
        kết thúc
    kết thúc
    hàm el:Refresh(newOptions, keepSelection, quiet)
        tùy chọn = bảng.clone(newOptions hoặc {})
        nếu là nhiều thì
            cục bộ được giữ = {}
            nếu giữ nguyên lựa chọn thì
                cho khóa trong các cặp (đã chọn) thực hiện
                    nếu chứa (tùy chọn, khóa) thì
                        kept[key] = true
                    kết thúc
                kết thúc
            kết thúc
            đã chọn = được giữ lại
        elseif not (keepSelection and state ~= nil and contains(options, state)) then
            trạng thái = tùy chọn[1]
        kết thúc
        rebuild()
        paintHeader()
        nếu mở thì
            resize()
        kết thúc
        nếu không yên tĩnh thì
            safe(o.Callback, multi và selectedList() hoặc state)
        kết thúc
    kết thúc
    trả về thanh ghi (o, el)
kết thúc


Hàm Tab:CreateDropdown(o)
    o = opt(o)
    return self:_dropdown(o, (o.MultipleOptions or o.Multi) == true)
kết thúc


hàm Tab:CreateInput(o)
    o = opt(o)
    cục bộ f = self:_row(42)
    văn bản(f, {
        Kích thước = UDim2.new(1, -170, 1, 0),
        Vị trí = UDim2.new(0, 14, 0, 0),
        Văn bản = tiêu đề của (o),
    })
    local default = o.CurrentValue or o.Default or o.Value
    trạng thái cục bộ = mặc định ~= nil và tostring(mặc định) hoặc ""
    hộp cục bộ = mới("TextBox", {
        AnchorPoint = Vector2.new(1, 0.5),
        Vị trí = UDim2.new(1, -10, 0.5, 0),
        Kích thước = UDim2.fromOffset(140, 26),
        BackgroundColor3 = Theme.Surface3,
        BorderSizePixel = 0,
        Phông chữ = FONT,
        Kích thước văn bản = 12,
        TextColor3 = Theme.Text,
        PlaceholderText = tostring(o.PlaceholderText or o.Placeholder or ""),
        PlaceholderColor3 = Theme.Muted,
        ClearTextOnFocus = false,
        Văn bản = trạng thái,
    }, f)
    round(box, 6)
    local boxStroke = outline(box, Theme.Stroke, 1, 1)
    box.Focused:Connect(function()
        tween(boxStroke, 0.15, { Transparency = 0 })
    hết)
    box.FocusLost:Connect(function()
        tween(boxStroke, 0.2, { Transparency = 1 })
        nếu o.Finished ≠ false thì
            trạng thái = hộp.Văn bản
            safe(o.Callback, state)
        kết thúc
    hết)
    box:GetPropertyChangedSignal("Text"):Connect(function()
        nếu o.Numeric == true thì
            local cleaned = box.Text:gsub("[^%d%.]", "")
            nếu được làm sạch ~= box.Text thì
                box.Text = đã được làm sạch
                trả về
            kết thúc
        kết thúc
        trạng thái = hộp.Văn bản
        nếu o.Finished == false thì
            safe(o.Callback, state)
        kết thúc
    hết)


    cục bộ el = {}
    hàm el:Get()
        trả về trạng thái
    kết thúc
    hàm el:Set(value, quiet)
        trạng thái = tostring(giá trị)
        box.Text = trạng thái
        nếu không im lặng và o.Finished ~= false thì
            safe(o.Callback, state)
        kết thúc
    kết thúc
    trả về thanh ghi (o, el)
kết thúc


hàm Tab:CreateKeybind(o)
    o = opt(o)
    cục bộ f = self:_row(42)
    văn bản(f, {
        Kích thước = UDim2.new(1, -120, 1, 0),
        Vị trí = UDim2.new(0, 14, 0, 0),
        Văn bản = tiêu đề của (o),
    })
    local current = keyFrom(o.CurrentKeybind or o.Default or o.Value)
    lắng nghe cục bộ = sai
    cục bộ lastFire = 0


    nút cục bộ = mới("Nút văn bản", {
        AnchorPoint = Vector2.new(1, 0.5),
        Vị trí = UDim2.new(1, -10, 0.5, 0),
        Kích thước = UDim2.fromOffset(90, 26),
        BackgroundColor3 = Theme.Surface3,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Phông chữ = FONT_BOLD,
        Kích thước văn bản = 12,
        TextColor3 = Theme.Text,
        Văn bản = hiện tại == Enum.KeyCode.Unknown và "Không có" hoặc tên hiện tại,
    }, f)
    round(button, 6)


    button.MouseButton1Click:Connect(function()
        nếu đang nghe thì
            trả về
        kết thúc
        đang lắng nghe = đúng
        button.Text = "..."
        tween(button, 0.15, { BackgroundColor3 = Theme.Accent, TextColor3 = Theme.AccentText })
        kết nối cục bộ
        connection = UserInputService.InputBegan:Connect(function(input)
            nếu input.UserInputType khác với Enum.UserInputType.Keyboard thì
                trả về
            kết thúc
            Kết nối: Ngắt kết nối()
            đang lắng nghe = sai
            lastFire = os.clock()
            Nếu input.KeyCode khác với Enum.KeyCode.Escape và input.KeyCode khác với mã hiện tại thì
                hiện tại = input.KeyCode
                safe(o.OnChanged, current.Name)
            kết thúc
            button.Text = current == Enum.KeyCode.Unknown and "None" or current.Name
            tween(button, 0.2, { BackgroundColor3 = Theme.Surface3, TextColor3 = Theme.Text })
        hết)
    hết)


    UserInputService.InputBegan:Connect(function(input)
        nếu đang lắng nghe hoặc input.UserInputType khác với Enum.UserInputType.Keyboard thì
            trả về
        kết thúc
        Nếu current ~= Enum.KeyCode.Unknown và input.KeyCode == current và không phải là UserInputService:GetFocusedTextBox() thì
            local now = os.clock()
            nếu hiện tại - lastFire > 0.15 thì
                lastFire = bây giờ
                safe(o.Callback)
            kết thúc
        kết thúc
    hết)


    cục bộ el = {}
    hàm el:Get()
        Trả về tên hiện tại
    kết thúc
    hàm el:Set(value)
        hiện tại = keyFrom(giá trị)
        button.Text = current == Enum.KeyCode.Unknown and "None" or current.Name
    kết thúc
    trả về thanh ghi (o, el)
kết thúc


---------------------------------------------------------------- cửa sổ
Cửa sổ cục bộ = {}
Window.__index = Window


Hàm Window:SelectTab(tab)
    nếu type(tab) ~= "table" hoặc không phải tab.Page thì
        trả về
    kết thúc
    cục bộ trước đó = self._active
    nếu previous == tab thì
        trả về
    kết thúc
    self._active = tab
    for _, other in ipairs(self._tabs) do
        cục bộ bật = khác == tab
        tween(other.Label, 0.2, { TextColor3 = on and Theme.Text or Theme.Muted })
        tween(other.Button, 0.2, { BackgroundTransparency = on and 0.4 or 1 })
        tween(other.Indicator, 0.2, { BackgroundTransparency = on and 0 or 1 })
        nếu không bật thì
            other.Page.Visible = false
        kết thúc
    kết thúc
    tab.Page.Position = UDim2.new(0, 0, 0, 10)
    tab.Page.Visible = true
    tween(tab.Page, 0.25, { Position = UDim2.new(0, 0, 0, 0) })
kết thúc


hàm Window:CreateTab(o)
    o = opt(o)
    tiêu đề cục bộ = tiêu đề của (o)


    nút cục bộ = mới("Nút văn bản", {
        Kích thước = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = Theme.Surface2,
        Độ trong suốt nền = 1,
        AutoButtonColor = false,
        Văn bản = "",
        LayoutOrder = #self._tabs + 1,
    }, self._tabList)
    round(button, 8)
    chỉ báo cục bộ = mới("Khung", {
        AnchorPoint = Vector2.new(0, 0.5),
        Vị trí = UDim2.new(0, 4, 0.5, 0),
        Kích thước = UDim2.fromOffset(3, 16),
        BackgroundColor3 = Theme.Accent,
        Độ trong suốt nền = 1,
        BorderSizePixel = 0,
    }, nút)
    round(chỉ báo, 2)
    indicator.BackgroundColor3 = Color3.new(1, 1, 1)
    gradient(chỉ báo, 90)
    nhãn cục bộ = văn bản(nút, {
        Kích thước = UDim2.new(1, -24, 1, 0),
        Vị trí = UDim2.new(0, 16, 0, 0),
        TextColor3 = Theme.Muted,
        Văn bản = tiêu đề,
    })


    trang cục bộ = mới("Khung cuộn", {
        Kích thước = UDim2.fromScale(1, 1),
        Độ trong suốt nền = 1,
        BorderSizePixel = 0,
        Độ dày thanh cuộn = 3,
        ScrollBarImageColor3 = Theme.Surface3,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Hiển thị = false,
    }, self._content)
    pad(page, 12, 10, 12, 12)
    new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, page)


    tab cục bộ = setmetatable({
        Nút = nút,
        Nhãn = nhãn,
        Indicator = indicator,
        Trang = trang,
        Window = self,
        _n = 0,
    }, Tab)
    table.insert(self._tabs, tab)


    button.MouseEnter:Connect(function()
        nếu self._active khác tab thì
            tween(button, 0.15, { BackgroundTransparency = 0.7 })
        kết thúc
    hết)
    button.MouseLeave:Connect(function()
        nếu self._active khác tab thì
            tween(button, 0.2, { BackgroundTransparency = 1 })
        kết thúc
    hết)
    button.MouseButton1Click:Connect(function()
        self:SelectTab(tab)
    hết)


    nếu #self._tabs == 1 thì
        self:SelectTab(tab)
    kết thúc
    tab trở lại
kết thúc


Hàm Window:Toggle(force)
    hiển thị cục bộ = buộc
    nếu show == nil thì
        hiển thị = không hiển thị
    kết thúc
    self._visible = hiển thị
    self._toggleToken = (self._toggleToken hoặc 0) + 1
    mã thông báo cục bộ = self._toggleToken
    local main = self._main
    local rest = self._basePos


    -- mỗi lần chỉ có một hiệu ứng chuyển động trung gian, vì vậy các thao tác chuyển đổi nhanh sẽ không bị giật hoặc gián đoạn.
    nếu self._toggleTween thì
        pcall(function() self._toggleTween:Cancel() end)
        self._toggleTween = nil
    kết thúc
    -- Các phiên bản cũ hơn đã tạo hiệu ứng chuyển động cho tỷ lệ; hãy đảm bảo rằng nó đã trở lại kích thước phù hợp.
    local sc = main:FindFirstChildOfClass("UIScale")
    local fitted = main:GetAttribute("FitScale")
    nếu sc và phù hợp thì
        sc.Scale = vừa khít
    kết thúc


    nếu hiển thị thì
        nếu main.Visible thì
            main.GroupTransparency = 1
            main.Position = rest + UDim2.fromOffset(0, 10)
            main.Visible = true
        kết thúc
        -- mờ dần và trượt lên trong một chuyển động nhanh duy nhất
        self._toggleTween = tween(main, 0.16, { GroupTransparency = 0, Position = rest }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    khác
        local closing = tween(main, 0.11, { GroupTransparency = 1, Position = rest + UDim2.fromOffset(0, 6) }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        self._toggleTween = closing
        closing.Completed:Connect(function(state)
            nếu state == Enum.PlaybackState.Completed và token == self._toggleToken và không hiển thị thì
                main.Visible = false
                main.Position = rest
            kết thúc
        hết)
    kết thúc
kết thúc


Hàm Window:SetKeybind(key)
    nếu kiểu của khóa là "EnumItem" thì
        self._toggleKey = key
    kết thúc
kết thúc


Hàm Window:Destroy()
    nếu self.Gui thì
        self.Gui:Destroy()
    kết thúc
kết thúc


Hàm Library:CreateWindow(o)
    o = opt(o)
    gốc cục bộ = getGui()
    Chiều rộng, chiều cao cục bộ = 600, 390


    local main = new("CanvasGroup", {
        Tên = "Chính",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Vị trí = UDim2.new(0.5, 0, 0.5, 0),
        Kích thước = UDim2.fromOffset(chiều rộng, chiều cao),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        GroupTransparency = 1,
    }, gốc)
    round(main, 12)
    gradient(outline(main, Color3.new(1, 1, 1), 1.5, 0.1), 45)
    tỷ lệ cục bộ = new("UIScale", {}, main)
    hàm cục bộ fit()
        camera cục bộ = workspace.CurrentCamera
        nếu là camera thì
            chế độ xem cục bộ = camera.ViewportSize
            local fitted = math.clamp(math.min(view.X * 0.94 / width, view.Y * 0.88 / height), 0.5, 1)
            scale.Scale = fitted
            main:SetAttribute("FitScale", fitted)
        kết thúc
    kết thúc
    fit()
    nếu workspace.CurrentCamera thì
        workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fit)
    kết thúc


    cửa sổ cục bộ = setmetatable({
        Gui = gốc,
        _main = chính,
        _tabs = {},
        _visible = false,
        _basePos = main.Position,
        _toggleKey = o.ToggleUIKeybind hoặc Enum.KeyCode.LeftControl,
    }, Window)


    -- Phông nền khoa học viễn tưởng: nền chuyển màu đậm, lớp phủ màu lục lam/tím nhạt và lưới bản vẽ kỹ thuật.
    -- Chỉ được xây dựng từ các khung hình, vì vậy nó không cần bất kỳ tài nguyên hình ảnh nào.
    phông nền cục bộ = mới("Khung", {
        Tên = "Hình nền",
        Kích thước = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        ZIndex = 0,
    }, main)
    new("UIGradient", {
        Màu = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(5, 8, 22)),
            ColorSequenceKeypoint.new(0.6, Color3.fromRGB(9, 11, 30)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 12, 46)),
        }),
        Xoay = 35,
    }, phông nền)

    giặt cục bộ = mới("Khung", {
        Tên = "Giặt",
        Kích thước = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        ZIndex = 0,
    }, main)
    new("UIGradient", {
        Màu = CHUỖI NHẤN,
        Xoay = 35,
        Độ trong suốt = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.88),
            NumberSequenceKeypoint.new(0.5, 0.97),
            NumberSequenceKeypoint.new(1, 0.88),
        }),
    }, wash)

    lưới cục bộ = mới("Khung", {
        Tên = "Lưới",
        Kích thước = UDim2.fromScale(1, 1),
        Độ trong suốt nền = 1,
        ClipsDescendants = true,
        ZIndex = 0,
    }, main)
    cục bộ GRID_STEP = 28
    for i = 0, math.ceil(width / GRID_STEP) do
        cục bộ mạnh = i % 4 == 0
        new("Frame", {
            Vị trí = UDim2.fromOffset(i * GRID_STEP, 0),
            Kích thước = UDim2.new(0, 1, 1, 0),
            BackgroundColor3 = strong và Theme.Cyan hoặc Color3.fromRGB(100, 120, 240),
            BackgroundTransparency = strong và 0.92 hoặc 0.96,
            BorderSizePixel = 0,
            ZIndex = 0,
        }, lưới)
    kết thúc
    for i = 0, math.ceil(height / GRID_STEP) do
        cục bộ mạnh = i % 4 == 0
        new("Frame", {
            Vị trí = UDim2.fromOffset(0, i * GRID_STEP),
            Kích thước = UDim2.new(1, 0, 0, 1),
            BackgroundColor3 = strong và Theme.Cyan hoặc Color3.fromRGB(100, 120, 240),
            BackgroundTransparency = strong và 0.92 hoặc 0.96,
            BorderSizePixel = 0,
            ZIndex = 0,
        }, lưới)
    kết thúc


    -- thanh tiêu đề
    cục bộ top = new("Khung", {
        Kích thước = UDim2.new(1, 0, 0, 46),
        BackgroundColor3 = Theme.Topbar,
        BackgroundTransparency = BAR_ALPHA,
        BorderSizePixel = 0,
    }, main)
    gradient(new("Frame", {
        AnchorPoint = Vector2.new(0, 1),
        Vị trí = UDim2.new(0, 0, 1, 0),
        Kích thước = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Color3.new(1, 1, 1),
        Độ trong suốt nền = 0.35,
        BorderSizePixel = 0,
    }, trên cùng), 0)


    văn bản cục bộ X = 54
    huy hiệu cục bộ = mới("Khung", {
        Tên = "LogoBadge",
        AnchorPoint = Vector2.new(0, 0.5),
        Vị trí = UDim2.new(0, 12, 0.5, 0),
        Kích thước = UDim2.fromOffset(32, 32),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
    }, trên cùng)
    new("UICorner", { CornerRadius = UDim.new(1, 0) }, badge)
    gradient(outline(badge, Color3.new(1, 1, 1), 1.5, 0), 45)
    Văn bản huy hiệu cục bộ = văn bản(huy hiệu, {
        Kích thước = UDim2.fromScale(1, 1),
        Phông chữ = Enum.Font.GothamBlack,
        Kích thước văn bản = 14,
        TextColor3 = Color3.new(1, 1, 1),
        TextXAlignment = Enum.TextXAlignment.Center,
        TextStrokeTransparency = 1,
        Văn bản = "AH",
    })
    gradient(badgeText, 45)
    local subtitle = tostring(o.Subtitle or "")
    văn bản(trên cùng, {
        Kích thước = UDim2.new(1, -textX - 60, 0, 18),
        Vị trí = UDim2.new(0, textX, 0, phụ đề ~= "" và 7 hoặc 14),
        Phông chữ = FONT_BOLD,
        Kích thước văn bản = 15,
        Văn bản = tostring(o.Name hoặc o.Title hoặc "namdz Hub"),
    })
    nếu phụ đề ~= "" thì
        văn bản(trên cùng, {
            Kích thước = UDim2.new(1, -textX - 60, 0, 14),
            Vị trí = UDim2.new(0, textX, 0, 25),
            Kích thước văn bản = 11,
            TextColor3 = Theme.Muted,
            Văn bản = phụ đề,
        })
    kết thúc


    local close = new("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Vị trí = UDim2.new(1, -10, 0.5, 0),
        Kích thước = UDim2.fromOffset(30, 30),
        BackgroundColor3 = Theme.Surface2,
        Độ trong suốt nền = 1,
        AutoButtonColor = false,
        Phông chữ = FONT_BOLD,
        Kích thước văn bản = 18,
        TextColor3 = Theme.Muted,
        Văn bản = "-",
    }, trên cùng)
    round(close, 8)
    đóng.MouseEnter:Connect(function()
        tween(close, 0.15, { BackgroundTransparency = 0, TextColor3 = Theme.Text })
    hết)
    close.MouseLeave:Connect(function())
        tween(close, 0.2, { BackgroundTransparency = 1, TextColor3 = Theme.Muted })
    hết)
    đóng.MouseButton1Click:Connect(function()
        window:Toggle(false)
        Thư viện:Notify({
            Tiêu đề = "Có"
            Content = "Nhấn " .. window._toggleKey.Name .. " hoặc chạm vào logo để mở lại.",
            Thời lượng = 3,
        })
    hết)


    -- kéo
    kéo cục bộ, dragStart, startPos = false, nil, nil
    top.InputBegan:Connect(function(input)
        nếu isPointer(input) thì
            kéo = đúng
            dragStart = input.Position
            startPos = main.Position
        kết thúc
    hết)
    UserInputService.InputChanged:Connect(function(input)
        nếu kéo và là Di chuyển(đầu vào) thì
            delta cục bộ = vị trí đầu vào - điểm bắt đầu kéo
            main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
            window._basePos = main.Position
        kết thúc
    hết)
    UserInputService.InputEnded:Connect(function(input)
        nếu kéo và là con trỏ (đầu vào) thì
            kéo = sai
        kết thúc
    hết)


    -- thanh bên + nội dung
    thanh bên cục bộ = mới("Khung", {
        Vị trí = UDim2.new(0, 0, 0, 46),
        Kích thước = UDim2.new(0, 150, 1, -46),
        BackgroundColor3 = Theme.Sidebar,
        BackgroundTransparency = BAR_ALPHA,
        BorderSizePixel = 0,
    }, main)
    new("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        Vị trí = UDim2.new(1, 0, 0, 0),
        Kích thước = UDim2.new(0, 1, 1, 0),
        BackgroundColor3 = Theme.Stroke,
        Độ trong suốt nền = 0.4,
        BorderSizePixel = 0,
    }, thanh bên)
    local tabList = new("ScrollingFrame", {
        Kích thước = UDim2.new(1, -1, 1, 0),
        Độ trong suốt nền = 1,
        BorderSizePixel = 0,
        Độ dày thanh cuộn = 0,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, thanh bên)
    pad(tabList, 8, 10, 8, 10)
    new("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, tabList)
    window._tabList = tabList


    nội dung cục bộ = mới("Khung", {
        Vị trí = UDim2.new(0, 150, 0, 46),
        Kích thước = UDim2.new(1, -150, 1, -46),
        Độ trong suốt nền = 1,
        ClipsDescendants = true,
    }, main)
    window._content = nội dung


    -- tab Trang chủ tùy chọn
    trang chủ cục bộ = o.Trang chủ
    nếu kiểu(trang chủ) == "bàn" thì
        tab cục bộ = cửa sổ:CreateTab({ Name = home.Name hoặc "Trang chủ" })
        nếu kiểu dữ liệu (home.Stats) == "table" thì
            tab:CreateSection(tostring(home.StatsTitle or "Session"))
            window.Stats = tab:CreateStatGrid({ Items = home.Stats, Columns = 3 })
        kết thúc
        tab:CreateParagraph({
            Tiêu đề = tostring(home.Title hoặc o.Name hoặc ""),
            Nội dung = tostring(home.Desc hoặc o.Subtitle hoặc ""),
        })
        nếu home.Discord thì
            tab:CreateButton({
                Tên = tostring(home.DiscordTitle hoặc "Discord"),
                Mô tả = "Sao chép liên kết mời",
                Callback = hàm()
                    cục bộ đã sao chép = sai
                    nếu kiểu (setclipboard) == "function" thì
                        copied = pcall(setclipboard, tostring(home.Discord))
                    kết thúc
                    Thư viện:Notify({
                        Tiêu đề = tostring(home.DiscordTitle hoặc "Discord"),
                        Nội dung = đã sao chép và "Liên kết mời đã được sao chép vào clipboard" hoặc tostring(home.Discord),
                        Thời lượng = 3,
                    })
                hết,
            })
        kết thúc
    kết thúc


    UserInputService.InputBegan:Connect(function(input)
        nếu input.UserInputType == Enum.UserInputType.Keyboard
            và input.KeyCode == window._toggleKey
            và không phải UserInputService:GetFocusedTextBox() thì
            window:Toggle()
        kết thúc
    hết)


    window:Toggle(true)
    cửa sổ trả về
kết thúc
Library.Window = Library.CreateWindow


Trả về Thư viện
kết thúc)()


--------------------------------------------------------------------------------
-- Ứng dụng namdz Hub
--------------------------------------------------------------------------------


local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
RunService cục bộ = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")


local LocalPlayer = Players.LocalPlayer
local Events = ReplicatedStorage:WaitForChild("Events")
local Info = ReplicatedStorage:WaitForChild("Info")
local DataFolder = ReplicatedStorage:WaitForChild("Data")
local PlayerData = DataFolder:WaitForChild(LocalPlayer.UserId)


local ToggleHotbar = Events:WaitForChild("ToggleHotbar")
local FishingEvent = Events:WaitForChild("Fishing")
local UpdateFishProgression = Events:WaitForChild("UpdateFishProgression")
local UseSkill = Events:WaitForChild("UseSkill")
local SellFish = Events:WaitForChild("SellFish")
local CraftBaitEvent = Events:WaitForChild("CraftBait")
local CraftRodEvent = Events:WaitForChild("CraftRod")
local RedeemCodeEvent = Events:WaitForChild("RedeemCode")
local EquipBaitEvent = Events:WaitForChild("EquipBait", 9e9)


Cấu hình cục bộ = {
    AutoCast = false,
    AutoCastMethod = "Instant",
    AntiStaff = false,
    Ẩn tên = false,
    NotificationsEnabled = true,
    Chế độ hiệu suất = false,
    Tùy chọn nâng cấp = {"Tiền mặt", "Cấp độ"},
    UpgradeMethod = "Ngay lập tức",
    Tự động tái sinh = false,
    FilterBossFish = false,
    FilterSecretFish = false,
    CastDelay = 1,
    AutoReel = false,
    AutoMiniGame = false,
    BossMode = "Bình thường",
    AutoBoss = false,
    AutoSecretBoss = false,
    AutoSkill = false,
    SkillOrder = {"Z", "X", "C", "V"},
    Tự động bán = false,
    AutoSellMethod = "Spam",
    SellDelay = 1,
    SelectedBuyBait = "",
    BuyBaitAmount = 1,
    BuyBaitDelay = 1,
    AutoBuyBait = false,
    SelectedBait = "",
    BaitAmount = 1,
    AutoCraftBait = false,
    SelectedRod = "",
    AutoCraftRod = false,
    SelectedIsland = "",
    SelectedNPC = "",
    SelectedPlayer = "",
    ESPEnabled = false,
    AntiAFK = true,
    FullBright = false,
    NoFog = false,
    LoopSpeedEnabled = false,
    WalkSpeed ​​= 30,
    NoclipEnabled = false,
    InfJumpEnabled = false,
    FlyEnabled = false,
    Tốc độ bay = 2,
    Phím tắt FlyKeybind = "F",
    FlyKeybindEnabled = true,
    NoclipKeybind = "J",
    NoclipKeybindEnabled = true,
    DisableAllKeybinds = false,
    SavedPos = false,
    AutoTPPos = false,
    AutoExecute = false,
    AutoRejoin = true,
    WebhookEnabled = false,
    WebhookUrl = "",
    WebhookInterval = 0,
    WebhookOnCatch = false,
    HideId = true,
    FakeNameEnabled = false,
    FakeName = "Player",
    FakeIdEnabled = false,
    FakeId = "",
    AutoFarmIsland = false,
    SelectedFarmIsland = "Đảo Khởi Đầu",
    AutoTicketQuest = false,
    AutoDailyQuest = false,
    TicketQuestMode = "Khó",
    AutoEquipBestBait = false,
    AutoEquipRod = false
}


local SAVE_FOLDER = "namdzHub"
local SAVE_FILE = SAVE_FOLDER .. "/HeavyweighFishingConfig.json"


hàm cục bộ SaveConfig()
    pcall(function()
        if not isfolder(SAVE_FOLDER) then makefolder(SAVE_FOLDER) end
        writefile(SAVE_FILE, HttpService:JSONEncode(Config))
    hết)
kết thúc


hàm cục bộ LoadConfig()
    pcall(function()
        nếu là tệp (SAVE_FILE) thì
            local decoded = HttpService:JSONDecode(readfile(SAVE_FILE))
            for k, v in pairs(decoded) do
                nếu Config[k] ~= nil thì
                    Config[k] = v
                kết thúc
            kết thúc
        kết thúc
    hết)
kết thúc


LoadConfig()
Config.AutoFarmIsland = false -- Chức năng Tự động nuôi cá đã bị loại bỏ khỏi giao diện người dùng
Library.NotificationsEnabled = Config.NotificationsEnabled ~= false
nếu type(Config.SkillOrder) ~= "table" thì
    Config.SkillOrder = {"Z", "X", "C", "V"}
khác
    local validKeys = {Z = true, X = true, C = true, V = true}
    cục bộ đã lọc = {}
    for _, k in ipairs(Config.SkillOrder) do
        nếu validKeys[k] và không tìm thấy bảng (filtered, k) thì
            table.insert(filtered, k)
        kết thúc
    kết thúc
    Config.SkillOrder = filtered
kết thúc


local queueTeleport = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport) or queueonteleport
local autoExecQueued = false
-- Kịch bản Tự động thực thi / Tự động tham gia lại sẽ bắt đầu lại sau khi dịch chuyển tức thời.
-- Hãy đặt liên kết đến nơi chứa tập lệnh NÀY (cùng một liên kết gốc mà bạn sử dụng để chạy nó).
-- LƯU Ý: liên kết này vẫn trỏ đến tập lệnh được lưu trữ BAN ĐẦU. Sau khi dịch chuyển/tự động kết nối lại
-- Trò chơi sẽ tải lại tất cả nội dung tại URL này, vì vậy hãy thay thế nó bằng liên kết gốc nơi có nội dung của BẠN
-- Tệp namdzHub.lua được lưu trữ, hoặc chức năng tự động thực thi sẽ khôi phục bản dựng cũ.
local autoExecPayload = [[
task.spawn(function()
    nếu trò chơi không được tải() thì
        game.Loaded:Wait()
    kết thúc
    local Players = game:GetService("Players")
    local HttpService = game:GetService("HttpService")
    local lp = Players.LocalPlayer
    trong khi không phải lp
        task.wait(0.2)
        lp = Players.LocalPlayer
    kết thúc
    lặp lại tác vụ. chờ (0.2) cho đến khi lp.Character và lp:FindFirstChild("PlayerGui")
    cho phép cục bộ = false
    pcall(function()
        nếu là tệp tin thì
            cho phép = sai
            nếu isfile("namdzHub/rejoin.flag") và delfile thì
                pcall(delfile, "namdzHub/rejoin.flag")
            kết thúc
            -- Chỉ chạy khi tùy chọn Tự động thực thi được bật trong cấu hình đã lưu
            nếu isfile("namdzHub/HeavyweighFishingConfig.json") thì
                local dec = HttpService:JSONDecode(readfile("namdzHub/HeavyweighFishingConfig.json"))
                cho phép = (type(dec) == "table" và dec.AutoExecute == true)
            kết thúc
        kết thúc
    hết)
    nếu không cho phép thì
        trả về
    kết thúc
    biến môi trường cục bộ = (getgenv và getgenv()) hoặc _G
    nếu env.namdzBootLock và (os.clock() - env.namdzBootLock) < 90 thì
        trả về
    kết thúc
    env.namdzBootLock = os.clock()
    nguồn cục bộ
    for _ = 1, 3 do
        kết thúc
        task.wait(3)
    kết thúc
    nếu nguồn thì
        local fn = loadstring(source)
        nếu fn thì
            fn()
        kết thúc
    kết thúc
hết)
]]


hàm cục bộ QueueAutoExecute(force)
    nếu không phải queueTeleport thì trả về end
    if not Config.AutoExecute then return end
    nếu autoExecQueued và không phải force thì trả về end
    nếu autoExecPayload:find("YOUR-USER", 1, true) thì
        pcall(function()
            Thư viện:Notify({
                Tiêu đề = "Tự động thực thi",
                Content = "Hãy đặt tập lệnh liên kết trong autoExecPayload trước.",
                Loại = "cảnh báo",
                Thời lượng = 6,
            })
        hết)
        trả về
    kết thúc
    autoExecQueued = true
    pcall(function()
        queueTeleport(autoExecPayload)
    hết)
kết thúc


nếu Config.AutoExecute thì
    QueueAutoExecute()
kết thúc


pcall(function()
    LocalPlayer.OnTeleport:Connect(function()
        nếu Config.AutoExecute thì
            QueueAutoExecute()
        kết thúc
    hết)
hết)


hàm cục bộ GetSavedCFrame()
    nếu type(Config.SavedPos) == "table" và #Config.SavedPos >= 3 thì
        cục bộ ok, cf = pcall(CFrame.new, unpack(Config.SavedPos))
        nếu ổn và cf thì
            trả về cf
        kết thúc
    kết thúc
    Trả về nil
kết thúc


Vị trí trang trại đảo địa phương = {
    ["Beginning Isle"] = CFrame.new(-297.48, 9.28, 58.78, 0.00, 0.00, 1.00, -0.00, 1.00, -0.00, -1.00, -0.00, 0.00),
    ["Đảo Tre"] = CFrame.new(-1310.04, 9.28, 29.79, -0.28, -0.00, 0.96, -0.00, 1.00, 0.00, -0.96, -0.00, -0.28),
    ["Fallout Isle"] = CFrame.new(76.47, 9.28, 1265.92, -1.00, 0.00, 0.01, 0.00, 1.00, -0.00, -0.01, -0.00, -1.00),
    ["Sovereign Isle"] = CFrame.new(-1254.18, 9.28, 1301.79, -1.00, 0.00, -0.07, 0.00, 1.00, -0.00, 0.07, -0.00, -1.00),
    ["Perch Isle"] = CFrame.new(-38.55, 9.28, -1343.82, 0.99, -0.00, -0.12, 0.00, 1.00, 0.00, 0.12, -0.00, 0.99),
    ["Đảo Băng"] = CFrame.new(-1348.71, 9.28, -1446.51, -1.00, -0.00, -0.03, -0.00, 1.00, 0.00, 0.03, 0.00, -1.00),
    ["Coconut Isle"] = CFrame.new(1431.00, 9.28, -1430.22, -0.17, 0.00, 0.98, -0.00, 1.00, -0.00, -0.98, -0.00, -0.17),
    ["Amber Isle"] = CFrame.new(1122.07, 9.28, 1414.54, 0.03, -0.00, 1.00, -0.00, 1.00, 0.00, -1.00, -0.00, 0.03),
    ["Battlefield Isle"] = CFrame.new(1249.73, 19.56, 68.87, 0.01, 0.00, 1.00, 0.00, 1.00, -0.00, -1.00, 0.00, 0.01),
    ["Đảo Mistpeak"] = CFrame.new(2549.02, 9.28, -80.77, -0.03, 0.00, 1.00, 0.00, 1.00, -0.00, -1.00, 0.00, -0.03),
    ["World Angler Isle"] = CFrame.new(-2345.67, 9.28, -203.65, -0.09, -0.00, -1.00, 0.00, 1.00, -0.00, 1.00, -0.00, -0.09),
    ["Weather Isle"] = CFrame.new(-2886.12, 6.76, 1199.79, -0.04, -0.00, -1.00, -0.00, 1.00, -0.00, 1.00, 0.00, -0.04),
    ["Đảo Rạn Huyền Bí"] = CFrame.new(-2561.58, 9.28, -1288.64, -0.07, -0.00, -1.00, 0.00, 1.00, -0.00, 1.00, -0.00, -0.07)
}


hàm cục bộ GetIslandFarmCFrame(islandKey)
    khóa cục bộ = islandKey hoặc Config.SelectedFarmIsland hoặc ""
    nếu IslandFarmPositions[key] thì
        trả về IslandFarmPositions[key]
    kết thúc
    local cleanKey = tostring(key):gsub("%s*|%s*%d+", ""):gsub("^%s+", ""):gsub("%s+$", "")
    nếu IslandFarmPositions[cleanKey] thì
        trả về IslandFarmPositions[cleanKey]
    kết thúc
    local lowerClean = string.lower(cleanKey)
    for name, cf in pairs(IslandFarmPositions) do
        local lName = string.lower(name)
        if lowerClean == lName or string.find(lowerClean, lName, 1, true) or string.find(lName, lowerClean, 1, true) then
            trả về cf
        kết thúc
    kết thúc
    Trả về nil
kết thúc


local ModuleCache = {}


hàm cục bộ GetModuleData(mod)
    if not mod or not mod:IsA("ModuleScript") then return nil end
    local cached = ModuleCache[mod]
    nếu cached ~= nil thì
        trả về cached ~= false và cached hoặc nil
    kết thúc
    cục bộ ok, data = pcall(require, mod)
    nếu ok và kiểu dữ liệu == "table" thì
        ModuleCache[mod] = dữ liệu
        dữ liệu trả về
    kết thúc
    ModuleCache[mod] = false
    Trả về nil
kết thúc


-- Chống AFK: Roblox sẽ tự động đá người chơi ra khỏi máy sau 20 phút không hoạt động (lỗi 278), sau đó sẽ tự động tham gia lại.
-- dẫn đến thay đổi máy chủ. Các trình xử lý trạng thái chờ cũ của Roblox sẽ bị vô hiệu hóa TRƯỚC TIÊN, và chỉ sau đó
-- sau đó chúng ta kết nối trình xử lý của riêng mình (trước đó, vòng lặp bên dưới cũng đã vô hiệu hóa trình xử lý của chính chúng ta).
nếu getconnections thì
    pcall(function()
        for _, conn in pairs(getconnections(LocalPlayer.Idled)) do
            nếu conn.Disable thì
                conn:Disable()
            nếu conn.Disconnect thì
                conn:Disconnect()
            kết thúc
        kết thúc
    hết)
kết thúc


local lastAfkTick = os.clock()


hàm cục bộ AntiAfkPulse()
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    hết)
    pcall(function()
        -- Phương án dự phòng: đầu vào thực nhỏ để bộ đếm thời gian chờ luôn được đặt lại
        VirtualInputManager:SendMouseMoveEvent(1, 1, game)
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftShift, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftShift, false, game)
    hết)
kết thúc


LocalPlayer.Idled:Connect(function()
    nếu không phải Config.AntiAFK thì trả về end
    AntiAfkPulse()
hết)


task.spawn(function()
    trong khi đúng thì
        task.wait(1)
        nếu Config.AntiAFK thì
            local now = os.clock()
            Nếu hiện tại - lastAfkTick >= 240 thì -- cứ sau mỗi 4 phút (việc đá người chơi ra khỏi máy khi đạt 20 phút)
                lastAfkTick = bây giờ
                AntiAfkPulse()
            kết thúc


            pcall(function()
                local afkVal = PlayerData and PlayerData:FindFirstChild("AFK")
                nếu afkVal và afkVal.Value == true thì
                    local afkEvent = Events:FindFirstChild("AFK")
                    nếu afkEvent thì
                        afkEvent:FireServer()
                    kết thúc
                kết thúc
            hết)
        khác
            lastAfkTick = os.clock()
        kết thúc
    kết thúc
hết)


local cachedChar = LocalPlayer.Character
local cachedHum = cachedChar and cachedChar:FindFirstChildOfClass("Humanoid")
local cachedHrp = cachedChar and cachedChar:FindFirstChild("HumanoidRootPart")
local cachedSkillsFolder = cachedChar and cachedChar:FindFirstChild("Skills")
local cachedStatsFolder = cachedChar and cachedChar:FindFirstChild("Stats")
local FishesFolder = workspace:FindFirstChild("Fishes")


local MainGui = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("MainGui")
local FishingGui = MainGui:WaitForChild("Fishing")
local BarFrame = FishingGui:WaitForChild("BarFrame")
local FishingBar = BarFrame:WaitForChild("Bar")
local SkillBtnFrame = FishingGui:WaitForChild("SkillButton"):WaitForChild("Frame")
local RhythmGui = FishingGui:FindFirstChild("Rhythm")
local BossFightBar = FishingGui:FindFirstChild("BossFightBar")
local MobileGui = MainGui:FindFirstChild("Mobile")
local MobileFishingBtn = MobileGui and MobileGui:FindFirstChild("Fishing")
local RhythmHitEvent = Events:FindFirstChild("RhythmHit")


hàm cục bộ RefreshGuiCache()
    nếu không phải MainGui hoặc không phải MainGui.Parent thì
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        MainGui = pg và pg:FindFirstChild("MainGui")
        FishingGui = MainGui và MainGui:FindFirstChild("Fishing")
        BarFrame = FishingGui và FishingGui:FindFirstChild("BarFrame")
        FishingBar = BarFrame và BarFrame:FindFirstChild("Bar")
        local sb = FishingGui and FishingGui:FindFirstChild("SkillButton")
        SkillBtnFrame = sb và sb:FindFirstChild("Frame")
        RhythmGui = FishingGui và FishingGui:FindFirstChild("Rhythm")
        BossFightBar = FishingGui và FishingGui:FindFirstChild("BossFightBar")
        MobileGui = MainGui và MainGui:FindFirstChild("Mobile")
        MobileFishingBtn = MobileGui và MobileGui:FindFirstChild("Fishing")
    khác
        nếu không phải RhythmGui hoặc không phải RhythmGui.Parent thì
            RhythmGui = FishingGui và FishingGui:FindFirstChild("Rhythm")
        kết thúc
        nếu không phải BossFightBar hoặc không phải BossFightBar.Parent thì
            BossFightBar = FishingGui và FishingGui:FindFirstChild("BossFightBar")
        kết thúc
        nếu không phải MobileFishingBtn hoặc không phải MobileFishingBtn.Parent thì
            MobileGui = MainGui và MainGui:FindFirstChild("Mobile")
            MobileFishingBtn = MobileGui và MobileGui:FindFirstChild("Fishing")
        kết thúc
    kết thúc
    nếu không phải là RhythmHitEvent thì
        RhythmHitEvent = Events:FindFirstChild("RhythmHit")
    kết thúc
    nếu không phải FishesFolder hoặc không phải FishesFolder.Parent thì
        FishesFolder = workspace:FindFirstChild("Fishes")
    kết thúc
kết thúc


local _noclipThrottle = 0
RunService.Stepped:Connect(function(_, dt)
    if not Config.NoclipEnabled and not Config.LoopSpeedEnabled then return end
    _noclipThrottle = _noclipThrottle + dt
    nếu _noclipThrottle < 0.08 thì trả về end
    _noclipThrottle = 0


    local char = cachedChar
    nếu không phải là char hoặc không phải là char.Parent thì trả về end


    nếu Config.NoclipEnabled thì
        for _, part in ipairs(char:GetChildren()) do
            nếu part:IsA("BasePart") và part.CanCollide thì
                part.CanCollide = false
            kết thúc
        kết thúc
    kết thúc


    Nếu Config.LoopSpeedEnabled và cachedHum và cachedHum.WalkSpeed ​​~= Config.WalkSpeed ​​thì
        cachedHum.WalkSpeed ​​= Config.WalkSpeed
    kết thúc
hết)


cục bộ lastInfJumpTick = 0


hàm cục bộ IsInsideOceanWater(hrp)
    nếu không phải hrp thì trả về false end
    local ocean = workspace:FindFirstChild("Ocean")
    nếu không phải là đại dương thì trả về false end
    vị trí cục bộ = hrp.Vị trí
    for _, child in ipairs(ocean:GetChildren()) do
        nếu child.Name == "Water" và child:IsA("BasePart") thì
            local half = child.Size * 0.5
            sự khác biệt cục bộ = vị trí của con - vị trí
            nếu math.abs(diff.X) <= half.X và math.abs(diff.Y) <= half.Y và math.abs(diff.Z) <= half.Z thì
                Trả về true
            kết thúc
        kết thúc
    kết thúc
    Trả về false
kết thúc


UserInputService.JumpRequest:Connect(function()
    if not Config.InfJumpEnabled then return end
    local now = os.clock()
    if now - lastInfJumpTick < 0.18 then return end
    local char = cachedChar or LocalPlayer.Character
    local hum = cachedHum or (char and char:FindFirstChildOfClass("Humanoid"))
    local hrp = cachedHrp or (char and char:FindFirstChild("HumanoidRootPart"))
    if not char or not hum or not hrp or hum.Health <= 0 then return end
    if char:GetAttribute("Swimming") == true or hrp:FindFirstChildOfClass("BodyPosition") or IsInsideOceanWater(hrp) then
        trả về
    kết thúc
    lastInfJumpTick = bây giờ
    hum:ChangeState(Enum.HumanoidStateType.Jumping)
hết)


local flyConnection = nil
local jumpStateConnection = nil


hàm cục bộ startFly()
    local char = LocalPlayer.Character
    nếu không phải là ký tự thì trả về end


    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")


    nếu không phải hrp hoặc không phải hình người thì trả về end


    humanoid.PlatformStand = true


    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Velocity = Vector3.zero
    bv.Parent = hrp


    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.P = 1e7
    bg.D = 12000
    bg.CFrame = hrp.CFrame
    bg.Parent = hrp


    jumpStateConnection = humanoid.StateChanged:Connect(function(_, new)
        nếu new == Enum.HumanoidStateType.Jumping hoặc new == Enum.HumanoidStateType.Freefall thì
            humanoid.PlatformStand = true
        kết thúc
    hết)


    flyConnection = RunService.RenderStepped:Connect(function()
        local cam = workspace.CurrentCamera
        di chuyển cục bộ = Vector3.zero
        local md = humanoid.MoveDirection


        nếu md.Magnitude > 0 thì
            local flatLook = Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z)
            local flatRight = Vector3.new(cam.CFrame.RightVector.X, 0, cam.CFrame.RightVector.Z)


            nếu flatLook.Magnitude > 0.01 và flatRight.Magnitude > 0.01 thì
                local fwdAmt = md:Dot(flatLook.Unit)
                local rightAmt = md:Dot(flatRight.Unit)


                move += cam.CFrame.LookVector * fwdAmt
                move += cam.CFrame.RightVector * rightAmt
            kết thúc
        kết thúc


        if move.Magnitude > 0 then move = move.Unit end
        bv.Velocity = move * Config.FlySpeed ​​* 50
        góc nhìn cục bộ = cam.CFrame.LookVector
        bg.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + look, Vector3.new(0, 1, 0))
    hết)
kết thúc


hàm cục bộ stopFly()
    local char = LocalPlayer.Character
    nếu không phải là ký tự thì trả về end


    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")


    nếu là người thì humanoid.PlatformStand = false kết thúc
    nếu jumpStateConnection thì
        jumpStateConnection:Disconnect()
        jumpStateConnection = nil
    kết thúc
    nếu flyConnection thì
        flyConnection:Disconnect()
        flyConnection = nil
    kết thúc
    nếu hrp thì
        for _, v in pairs(hrp:GetChildren()) do
            nếu v:IsA("BodyVelocity") hoặc v:IsA("BodyGyro") thì
                v:Destroy()
            kết thúc
        kết thúc
    kết thúc
kết thúc


hàm cục bộ IsAntiConfuseActive()
    Trả về Config.AutoSkill hoặc Config.AutoMiniGame hoặc Config.AutoBoss hoặc Config.AutoSecretBoss hoặc Config.AutoFarmIsland
kết thúc


hàm cục bộ ApplyAntiConfuse(char)
    if not IsAntiConfuseActive() then return end
    nếu char thì
        nếu char:GetAttribute("Confused") == true thì
            pcall(function() char:SetAttribute("Confused", false) end)
        kết thúc
        nếu char:GetAttribute("SkillLocked") == true thì
            pcall(function() char:SetAttribute("SkillLocked", false) end)
        kết thúc
    kết thúc
    nếu SkillBtnFrame thì
        cho _, btn trong ipairs(SkillBtnFrame:GetChildren()) làm
            nếu btn:IsA("TextButton") thì
                khóa cục bộ = btn:FindFirstChild("Lock")
                nếu khóa và khóa.Visible thì
                    lock.Visible = false
                kết thúc
            kết thúc
        kết thúc
    kết thúc
    nếu FishingGui thì
        local hpPlayer = FishingGui:FindFirstChild("HPPlayer")
        local debuff = hpPlayer and hpPlayer:FindFirstChild("Debuff")
        local confusedGui = debuff and debuff:FindFirstChild("Confused")
        nếu confusedGui thì
            pcall(function() confusedGui:Destroy() end)
        kết thúc
    kết thúc
kết thúc


local antiConfuseConns = {}


hàm cục bộ BindCharacterAntiConfuse(char)
    for _, c in ipairs(antiConfuseConns) do
        pcall(function() c:Disconnect() end)
    kết thúc
    table.clear(antiConfuseConns)
    nếu không phải là ký tự thì trả về end
    table.insert(antiConfuseConns, char:GetAttributeChangedSignal("Confused"):Connect(function()
        nếu IsAntiConfuseActive() và char:GetAttribute("Confused") == true thì
            ApplyAntiConfuse(char)
        kết thúc
    hết))
    table.insert(antiConfuseConns, char:GetAttributeChangedSignal("SkillLocked"):Connect(function()
        nếu IsAntiConfuseActive() và char:GetAttribute("SkillLocked") == true thì
            ApplyAntiConfuse(char)
        kết thúc
    hết))
    nếu IsAntiConfuseActive() thì
        ApplyAntiConfuse(char)
    kết thúc
kết thúc


hàm cục bộ StepAutoTPPos(char)
    if not Config.AutoTPPos then return end
    nếu Config.AutoBoss hoặc Config.AutoSecretBoss thì trả về end
    local targetCF = GetSavedCFrame()
    nếu không phải targetCF thì trả về end
    local c = char or cachedChar or LocalPlayer.Character
    local hrp = (c and c:FindFirstChild("HumanoidRootPart")) or cachedHrp
    nếu hrp và (hrp.Position - targetCF.Position).Magnitude > 5 thì
        hrp.CFrame = targetCF
    kết thúc
kết thúc


hàm cục bộ StepAutoFarmIsland(char)
    if not Config.AutoFarmIsland then return end
    nếu Config.AutoBoss hoặc Config.AutoSecretBoss thì trả về end
    local targetCF = GetIslandFarmCFrame()
    nếu không phải targetCF thì trả về end
    local c = char or cachedChar or LocalPlayer.Character
    local hrp = (c and c:FindFirstChild("HumanoidRootPart")) or cachedHrp
    nếu hrp và (hrp.Position - targetCF.Position).Magnitude > 5 thì
        hrp.CFrame = targetCF
    kết thúc
kết thúc


nếu cachedChar thì
    BindCharacterAntiConfuse(cachedChar)
    task.spawn(function()
        StepAutoTPPos(cachedChar)
        StepAutoFarmIsland(cachedChar)
    hết)
kết thúc


LocalPlayer.CharacterAdded:Connect(function(newChar)
    cachedChar = newChar
    cachedHum = newChar:WaitForChild("Humanoid", 5)
    cachedHrp = newChar:WaitForChild("HumanoidRootPart", 5)
    cachedSkillsFolder = newChar:WaitForChild("Skills", 5)
    cachedStatsFolder = newChar:WaitForChild("Stats", 5)
    BindCharacterAntiConfuse(newChar)
    task.wait(0.3)
    StepAutoTPPos(newChar)
    StepAutoFarmIsland(newChar)
    nếu Config.FlyEnabled thì
        startFly()
    kết thúc
hết)


local minigameOpenTick = 0
cục bộ wasMinigameVisible = false
cục bộ bossPhase2SetupUntil = 0


làm
    local bp2 = Events:FindFirstChild("BossPhase2Setup")
    nếu bp2 và bp2:IsA("RemoteEvent") thì
        bp2.OnClientEvent:Connect(function())
            bossPhase2SetupUntil = os.clock() + 5
        hết)
    kết thúc
kết thúc


local IsGameAllowingSkill, IsSkillSlotAvailable, IsSkillOnCooldown, IsSkillKeyReady, namdzFilter, TriggerGuiButton
làm
hàm cục bộ FindSkillNumberValue(char, key)
    local skillsFolder = cachedSkillsFolder or (char and char:FindFirstChild("Skills"))
    if not skillsFolder then return nil, nil end
    for _, s in ipairs(skillsFolder:GetChildren()) do
        nếu s:IsA("NumberValue") thì
            local k = s:GetAttribute("Key") or s.Name
            nếu tostring(k) == key thì
                trả về s, skillsFolder
            kết thúc
        kết thúc
    kết thúc
    Trả về nil, skillsFolder
kết thúc


hàm cục bộ FindSkillButton(key)
    if not SkillBtnFrame then return nil end
    local direct = SkillBtnFrame:FindFirstChild(key)
    nếu là đường dẫn trực tiếp thì trả về kết thúc trực tiếp
    for _, child in ipairs(SkillBtnFrame:GetChildren()) do
        nếu child:IsA("GuiObject") thì
            if tostring(child:GetAttribute("Key") or "") == key then
                trả về phần tử con
            kết thúc
            for _, desc in ipairs(child:GetDescendants()) do
                nếu desc:IsA("TextLabel") và desc.Name ~= "CD" và desc.Text == key thì
                    trả về phần tử con
                kết thúc
            kết thúc
        kết thúc
    kết thúc
    Trả về nil
kết thúc


hàm IsGameAllowingSkill(char)
    nếu không phải FishingGui hoặc không phải FishingGui.Visible thì
        wasMinigameVisible = false
        Trả về false
    kết thúc


    nếu không phải là trò chơi nhỏ hiển thị thì
        wasMinigameVisible = true
        minigameOpenTick = os.clock()
    kết thúc


    nếu (RhythmGui và RhythmGui.Visible) hoặc (BossFightBar và BossFightBar.Visible) thì
        Trả về false
    kết thúc


    nếu char:GetAttribute("Phase2") == true thì
        bossPhase2SetupUntil = 0
        Trả về false
    kết thúc


    nếu bossPhase2SetupUntil > 0 và os.clock() < bossPhase2SetupUntil thì
        Trả về false
    kết thúc


    nếu không phải IsAntiConfuseActive() thì
        nếu char:GetAttribute("SkillLocked") hoặc char:GetAttribute("Confused") thì
            Trả về false
        kết thúc
    khác
        ApplyAntiConfuse(char)
    kết thúc


    local stats = cachedStatsFolder or char:FindFirstChild("Stats")
    nếu stats và stats:FindFirstChild("Stun") và stats.Stun.Value == true thì
        Trả về false
    kết thúc


    cá địa phươngId = LocalPlayer:GetAttribution("FishID")
    local fishObj = (fishId and FishesFolder) and FishesFolder:FindFirstChild(tostring(fishId)) or nil
    nếu fishObj thì
        local readyVal = fishObj:FindFirstChild("Ready")
        nếu readyVal thì
            nếu readyVal.Value khác true thì
                Trả về false
            kết thúc
        elseif os.clock() - minigameOpenTick < 3.1 then
            Trả về false
        kết thúc
        nếu fishObj:GetAttribute("FinalPhase") == true hoặc fishObj:GetAttribute("PreFinalPhase") == true thì
            Trả về false
        kết thúc
    elseif os.clock() - minigameOpenTick < 3.1 then
        Trả về false
    kết thúc


    local skillsFolder = cachedSkillsFolder or char:FindFirstChild("Skills")
    nếu skillsFolder thì
        for _, s in ipairs(skillsFolder:GetChildren()) do
            nếu s:IsA("NumberValue") và (s:GetAttribute("UsingSkill") hoặc 0) > 0 thì
                Trả về false
            kết thúc
        kết thúc
    kết thúc


    Trả về true
kết thúc


hàm IsSkillSlotAvailable(char, key)
    nếu PlayerData thì
        local rodVal = PlayerData:FindFirstChild("FishingRod")
        local rodInv = PlayerData:FindFirstChild("FishingRodInventory")
        local rf = (rodVal and rodVal.Value ~= "" and rodInv) and rodInv:FindFirstChild(rodVal.Value) or nil
        local skFolder = rf and rf:FindFirstChild("Skill")
        local skVal = skFolder and skFolder:FindFirstChild(key)
        nếu skVal và skVal:IsA("StringValue") thì
            return skVal.Value ~= ""
        kết thúc
    kết thúc
    local btn = FindSkillButton(key)
    nếu nút thì
        return btn.Visible == true
    kết thúc
    local s = FindSkillNumberValue(char, key)
    trả về s ~= nil
kết thúc


hàm IsSkillOnCooldown(char, key)
    local btn = FindSkillButton(key)
    nếu nút thì
        local cd = btn:FindFirstChild("CD")
        nếu cd và cd.Visible thì
            local txt = cd.Text or ""
            local num = tonumber(string.match(txt, "%d+%.?%d*"))
            nếu num và num > 0 thì
                Trả về true
            kết thúc
        kết thúc
    kết thúc
    local s = FindSkillNumberValue(char, key)
    nếu s và (s.Value > 0 hoặc (s:GetAttribute("UsingSkill") hoặc 0) > 0) thì
        Trả về true
    kết thúc
    Trả về false
kết thúc


hàm cục bộ IsSkillConfirmedUsed(char, key)
    trả về IsSkillOnCooldown(char, key)
kết thúc


hàm IsSkillKeyReady(char, key)
    nếu không có IsSkillSlotAvailable(char, key) thì
        Trả về false
    kết thúc


    nếu IsSkillOnCooldown(char, key) thì
        Trả về false
    kết thúc


    local btn = FindSkillButton(key)
    nếu nút thì
        nếu nút không hiển thị thì
            Trả về false
        kết thúc
        khóa cục bộ = btn:FindFirstChild("Lock")
        nếu khóa và khóa.Visible thì
            nếu IsAntiConfuseActive() thì
                lock.Visible = false
            khác
                Trả về false
            kết thúc
        kết thúc
    kết thúc


    local s, skillsFolder = FindSkillNumberValue(char, key)
    nếu s thì
        Trả về true
    kết thúc


    nếu skillsFolder và #skillsFolder:GetChildren() > 0 thì
        Trả về false
    kết thúc


    return btn ~= nil and btn.Visible == true
kết thúc


Nhịp điệu cục bộ Lanes = {"A", "S", "D"}
local rhythmKeyMap = {
    A = Enum.KeyCode.A,
    S = Enum.KeyCode.S,
    D = Enum.KeyCode.D
}
local lastRhythmLaneHit = { A = 0, S = 0, D = 0 }
cục bộ lastRhythmScan = 0
cục bộ lastPhase2HitTick = 0
local phase2BarHistory = {}
local CENTER_BAR_POS = UDim2.new(0.5, 0, 0.5, 0)
local isLockingBar = false
local barPosConn = nil
local boundBar = nil


-- Bộ lọc cá: Chế độ Tự động câu tiếp tục cho đến khi câu được cá Trùm/Trùm bí mật cắn câu.
namdzFilter = { Skip = false, Cache = {}, LastNotify = 0, AntiChecked = {} }


hàm cục bộ LockFishingBar()
    nếu isLockingBar thì trả về end
    nếu namdzFilter.Skip thì trả về end
    if not FishingGui or not FishingGui.Visible or not FishingBar then return end
    if not (Config.AutoReel or Config.AutoMiniGame or Config.AutoBoss or Config.AutoSecretBoss or Config.AutoFarmIsland) then return end
    isLockingBar = true
    local char = cachedChar
    nếu char và (tonumber(char:GetAttribute("GuildPower")) hoặc 0) < 99999999 thì
        pcall(function()
            char:SetAttribute("GuildPower", 99999999)
            local stats = cachedStatsFolder or char:FindFirstChild("Stats")
            local rp = stats and stats:FindFirstChild("RodPower")
            nếu rp thì
                local orig = rp.Value
                rp.Value = original + 1
                rp.Value = gốc
            kết thúc
        hết)
    kết thúc
    pcall(function()
        FishingBar:TweenPosition(CENTER_BAR_POS, Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0, true)
        FishingBar.Position = CENTER_BAR_POS
    hết)
    isLockingBar = false
kết thúc


hàm cục bộ BindFishingBarLock()
    nếu FishingBar và FishingBar ~= boundBar thì
        nếu barPosConn thì
            pcall(function() barPosConn:Disconnect() end)
            barPosConn = nil
        kết thúc
        boundBar = FishingBar
        barPosConn = FishingBar:GetPropertyChangedSignal("Position"):Connect(function()
            nếu không phải là thanh khóa và FishingBar.Position.X.Scale ~= 0.5 thì
                LockFishingBar()
            kết thúc
        hết)
    kết thúc
kết thúc


BindFishingBarLock()


hàm TriggerGuiButton(btn)
    nếu không phải là btn thì trả về false.
    nếu không btn:IsA("GuiButton") thì
        btn = btn:FindFirstChildWhichIsA("GuiButton", true) hoặc (btn.Parent và btn.Parent:IsA("GuiButton") và btn.Parent) hoặc nil
        nếu không phải là btn thì trả về false.
    kết thúc
    cục bộ được kích hoạt = sai
    local sigNames = {"MouseButton1Click", "Activated", "MouseButton1Down", "MouseButton1Up"}
    nếu getconnections thì
        for _, sName in ipairs(sigNames) do
            local okSig, sig = pcall(function() return btn[sName] end)
            nếu okSig và sig thì
                pcall(function()
                    for _, conn in pairs(getconnections(sig)) do
                        nếu conn.Function thì
                            task.spawn(conn.Function)
                            đã kích hoạt = đúng
                        nếu conn.Fire thì
                            conn:Fire()
                            đã kích hoạt = đúng
                        kết thúc
                    kết thúc
                hết)
            kết thúc
        kết thúc
    kết thúc
    nếu firesignal thì
        for _, sName in ipairs(sigNames) do
            pcall(function()
                firesignal(btn[sName])
                đã kích hoạt = đúng
            hết)
        kết thúc
    kết thúc
    trả về được kích hoạt
kết thúc


local getupval = (debug and debug.getupvalue) or getupvalue


hàm cục bộ StepPhase2MiniGame()
    nếu không phải BossFightBar hoặc không phải BossFightBar.Visible thì
        nếu #phase2BarHistory > 0 thì
            table.clear(phase2BarHistory)
        kết thúc
        trả về
    kết thúc


    local bar = BossFightBar:FindFirstChild("Bar")
    local hitbox = BossFightBar:FindFirstChild("Hitbox")
    nếu không phải thanh hoặc không phải vùng va chạm thì trả về end


    local barW = bar.Size.X.Scale
    local barCenter = bar.Position.X.Scale + barW * (0.5 - bar.AnchorPoint.X)
    local hbW = hitbox.Size.X.Scale
    local hbLeft = hitbox.Position.X.Scale - hbW * hitbox.AnchorPoint.X


    local now = os.clock()
    table.insert(phase2BarHistory, { t = now, x = barCenter })
    trong khi #phase2BarHistory > 1 và (now - phase2BarHistory[1].t) > 0.15 thì
        table.remove(phase2BarHistory, 1)
    kết thúc


    local handledViaUpval = false
    local onClickFn = nil


    nếu getconnections và getupval và MobileFishingBtn thì
        pcall(function()
            for _, conn in pairs(getconnections(MobileFishingBtn.MouseButton1Down)) do
                local fn = conn.Function and getupval(conn.Function, 1)
                nếu kiểu(fn) == "function" thì
                    onClickFn = fn
                    local u12 = getupval(fn, 1)
                    local u14 = getupval(fn, 2)
                    local u27 = getupval(fn, 3)
                    local u26 = getupval(fn, 4)
                    local u1 = getupval(fn, 5)
                    local u25 = getupval(fn, 6)
                    local u23 = getupval(fn, 7)
                    local u2 = getupval(fn, 8)
                    local u15 = getupval(fn, 9)
                    nếu u12 == true và type(u14) == "number" và type(u27) == "number" và type(u26) == "number" và type(u1) == "number" và type(u25) == "number" và type(u23) == "number" và type(u2) == "number" và type(u15) == "number" thì
                        nếu math.abs(u2 - hbW) < 0.005 và math.abs(u15 - hbLeft) < 0.005 thì
                            handledViaUpval = true
                            nếu now - u14 >= 0.035 và now - lastPhase2HitTick >= 0.035 thì
                                local v91 = (now - 0.025 - u27) % u26 * u1
                                nếu u25 < v91 thì
                                    v91 = u25 * 2 - v91
                                kết thúc
                                cục bộ v92 = u23 + v91
                                cục bộ v93 = u2 * 0.3
                                nếu v92 >= (u15 - v93 * 0.8) và v92 <= (u15 + u2 + v93 * 0.8) thì
                                    lastPhase2HitTick = bây giờ
                                    fn(false)
                                kết thúc
                            kết thúc
                        kết thúc
                        ngắt
                    kết thúc
                kết thúc
            kết thúc
        hết)
    kết thúc


    nếu được xử lý thông qua Upval thì trả về end
    nếu now - lastPhase2HitTick < 0.04 thì trả về end


    local evalX = barCenter
    targetTime cục bộ = hiện tại - 0.041
    for i = #phase2BarHistory, 1, -1 do
        nếu phase2BarHistory[i].t <= targetTime thì
            evalX = phase2BarHistory[i].x
            ngắt
        kết thúc
    kết thúc


    miếng đệm cục bộ = hbW * 0.2


    local badBox = BossFightBar:FindFirstChild("HitboxBad")
    nếu badBox và badBox.Visible thì
        local badW = badBox.Size.X.Scale
        local badLeft = badBox.Position.X.Scale - badW * badBox.AnchorPoint.X
        nếu evalX >= (badLeft - 0.01) và evalX <= (badLeft + badW + 0.01) thì
            trả về
        kết thúc
    kết thúc


    nếu evalX >= (hbLeft - pad) và evalX <= (hbLeft + hbW + pad) thì
        lastPhase2HitTick = bây giờ
        cục bộ đã nhấp chuột = false
        nếu onClickFn thì
            pcall(function()
                onClickFn(false)
                đã nhấp chuột = đúng
            hết)
        kết thúc
        nếu không nhấp vào và MobileFishingBtn thì
            nếu getconnections thì
                pcall(function()
                    for _, conn in pairs(getconnections(MobileFishingBtn.MouseButton1Down)) do
                        nếu conn.Function thì
                            task.spawn(conn.Function)
                            đã nhấp chuột = đúng
                        nếu conn.Fire thì
                            conn:Fire()
                            đã nhấp chuột = đúng
                        kết thúc
                    kết thúc
                hết)
            kết thúc
            nếu không nhấp chuột và phát tín hiệu thì
                pcall(function()
                    firesignal(MobileFishingBtn.MouseButton1Down)
                    đã nhấp chuột = đúng
                hết)
            kết thúc
        kết thúc
        nếu không nhấp chuột thì
            pcall(function()
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                task.delay(0.01, function()
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                hết)
            hết)
        kết thúc
    kết thúc
kết thúc
…
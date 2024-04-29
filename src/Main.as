UI::Font@ g_mono;
UI::Font@ droidsans26;
UI::Font@ droidsans20;
UI::Font@ droidsans16;

void Main(){
    startnew(LoadFonts);
}

void LoadFonts() {
    @g_mono = UI::LoadFont("DroidSansMono.ttf", 16);
    @droidsans26 = UI::LoadFont("DroidSans.ttf", 26, -1, -1, true, true, true);
    @droidsans20 = UI::LoadFont("DroidSans.ttf", 20, -1, -1, true, true, true);
    @droidsans16 = UI::LoadFont("DroidSans.ttf", 16, -1, -1, true, true, true);
}

enum Fonts {
    Mono,
    Normal,
    Bigger,
    Biggest,
}

UI::Font@ GetFont(Fonts font) {
    switch (font) {
        case Fonts::Mono: return g_mono;
        case Fonts::Normal: return droidsans16;
        case Fonts::Bigger: return droidsans20;
        case Fonts::Biggest: return droidsans26;
    }
    return droidsans16;
}

[Setting hidden]
bool g_visible = true;

[Setting category="General" name="Font Size"]
Fonts S_Font = Fonts::Biggest;

[Setting category="General" name="Show Camera Speed"]
bool S_ShowSpeed = false;

[Setting category="General" name="Show Camera FoV"]
bool S_ShowFoV = false;

[Setting category="General" name="Show Camera Near/Far Clip"]
bool S_ShowClipPlanes = false;

const string PLUGIN_NAME = Meta::ExecutingPlugin().Name;

void RenderMenu() {
    if (UI::MenuItem(PLUGIN_NAME, "", g_visible)) {
        g_visible = !g_visible;
    }
}

float g_dt;
void Update(float dt) {
    g_dt = dt;
}

void Render() {
    if (!g_visible) return;
    int flags = UI::WindowFlags::AlwaysAutoResize | UI::WindowFlags::NoCollapse;
    if (!UI::IsOverlayShown()) {
        flags |= UI::WindowFlags::NoTitleBar;
    }
    if (UI::Begin("Camera Coords", g_visible, flags)) {
        UI::PushFont(GetFont(S_Font));
        DrawMainInner();
        UI::PopFont();
    }
    UI::End();
}

float lastSpeed = 0;

void DrawMainInner() {
    auto cam = Camera::GetCurrent();
    if (cam is null) {
        UI::Text("No Camera.");
        return;
    }
    auto pos = Camera::GetCurrentPosition();
    CopiableLabeledValue("Cam Pos", pos.ToString());
    if (S_ShowSpeed) {
        auto app = GetApp();
        auto vp = cast<CDx11Viewport>(app.Viewport);
        auto lastSpeed = (lastSpeed + (cam.Vel.Length() * 3600.0 / g_dt)) / 2.;
        CopiableLabeledValue("Speed (km/h)", Text::Format("%.1f", lastSpeed));
    }
    if (S_ShowFoV) {
        CopiableLabeledValue("FoV", tostring(cam.Fov));
    }
    if (S_ShowClipPlanes) {
        CopiableLabeledValue("Near Clip", tostring(cam.NearZ));
        CopiableLabeledValue("Far Clip", tostring(cam.FarZ));
    }
}

void CopiableLabeledValue(const string &in label, const string &in value) {
    UI::Text(label + ":");
    UI::SameLine();
    UI::Text(value);
    if (UI::IsItemHovered()) {
        UI::SetMouseCursor(UI::MouseCursor::Hand);
    }
    if (UI::IsItemClicked()) {
        IO::SetClipboard(value);
        Notify("Copied: " + value);
    }
}

void Notify(const string &in msg) {
    UI::ShowNotification(Meta::ExecutingPlugin().Name, msg);
    trace("Notified: " + msg);
}

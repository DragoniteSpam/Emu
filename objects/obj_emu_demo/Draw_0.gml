// Render backdrop.
EmuOverlay.Render();

// Render docked containers.
containerL.Render();
containerR.Render();
containerPreview.Render();

// Render fly windows.
event_inherited();

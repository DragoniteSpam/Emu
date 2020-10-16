randomize();

data = {
    // bio
    
    name: "Sam",
    nickname: choose("Samwise", "Samcastle", "Samwich", "I Sam Corrected",
        "Kpop Sam", "United We Sam", "Comic Sams", "Samsquatch", "Consamtinople",
        "Green Eggs and Sam", "Hoover Sam", "Don't Give a Sam"),
    
    pronouns: irandom(2),
    hometown: irandom(8),
    alignment: irandom(8),
    // appearance
    size: irandom_range(4, 10) / 10,
    sprite: choose(spr_emu_demo_birb_yellow, spr_emu_demo_birb_red, spr_emu_demo_birb_blue),
    // stats
    str: irandom_range(-5, 5),
    dex: irandom_range(-5, 5),
    con: irandom_range(-5, 5),
    int: irandom_range(-5, 5),
    wis: irandom_range(-5, 5),
    cha: irandom_range(-5, 5),
    level: irandom_range(1, 5),
    // skills
    skills: ds_list_create(),
    // summary
    summary: choose("Likes bacon, lettuce and tomatoes.", "Once walked a tightrope between the Twin Towers.", "Actually dreams in code.", "Has a pet Mimic named Douglas the Dingbat.", "Always plays as a Nord.", "Grew up believing in Santa Claus."),
};

all_hometowns = ds_list_create();
ds_list_add(all_hometowns, "Alcamoth", "Hogwarts", "Markarth", "Mordor", "Narnia", "New Bark", "The Shire", "Wyoming", "Zanarkand");

all_alignments = ds_list_create();
ds_list_add(all_alignments, "Lawful Good", "Lawful Neutral", "Lawful Evil", "Neutral Good", "Boring", "Neutral Evil", "Chaotic Good", "Chaotic Neutral", "Chaotic Evil");

container = new EmuCore(32, 32, 640, 640);

var tab_group = new EmuTabGroup(0, 0, 640, 640, 2, 32);
var tab_bio = new EmuTab("Bio");
var tab_look = new EmuTab("Appearance");
var tab_stats = new EmuTab("Stats");
var tab_skills = new EmuTab("Skills");
var tab_summary = new EmuTab("Summary");

tab_group.AddTabs(0, [tab_bio, tab_look]);
tab_group.AddTabs(1, [tab_stats, tab_skills, tab_summary]);

container.AddContent(tab_group);

#region bio
tab_bio.AddContent([
    new EmuText(32, EMU_AUTO, 512, 32, "[c_blue]Character Bio[/c]"),
    new EmuInput(32, EMU_AUTO, 512, 32, "Name:", data.name, "enter a name", 32, E_InputTypes.STRING, function() {
        obj_emu_demo.data.name = value;
    }),
    new EmuInput(32, EMU_AUTO, 512, 32, "Nickname:", data.nickname, "enter a nickname", 32, E_InputTypes.STRING, function() {
        obj_emu_demo.data.nickname = value;
    }),
]);

var radio_gender = new EmuRadioArray(32, EMU_AUTO, 512, 32, "Pronouns:", data.pronouns, function() {
    obj_emu_demo.data.pronouns = value;
});

radio_gender.AddOptions(["They / them", "He / him", "She / her"]);
radio_gender.SetColumns(1, 160);
tab_bio.AddContent(radio_gender);

var list_hometown = new EmuList(32, EMU_AUTO, 256, 32, "Hometown:", 32, 8, function() {
    var selection = GetSelection();
    if (selection > -1) {
        obj_emu_demo.data.hometown = selection;
    }
});
list_hometown.SetList(all_hometowns);
list_hometown.Select(data.hometown, true);
tab_bio.AddContent(list_hometown);

var list_alignment = new EmuList(320, list_hometown.y, 256, 32, "Alignment:", 32, 8, function() {
    var selection = GetSelection();
    if (selection > -1) {
        obj_emu_demo.data.alignment = selection;
    }
});
list_alignment.SetList(all_alignments);
list_alignment.Select(data.alignment, true);
tab_bio.AddContent(list_alignment);
#endregion

#region appearance
tab_look.AddContent([
    new EmuText(32, EMU_AUTO, 256, 32, "[c_blue]Visual Appearance[/c]"),
    new EmuText(32, EMU_AUTO, 256, 32, "Size:"),
    new EmuProgressBar(32, EMU_AUTO, 256, 32, 12, 0.4, 1, true, data.size, function() {
        obj_emu_demo.data.size = value;
    }),
]);

var list_sprites = new EmuList(32, EMU_AUTO, 256, 32, "Sprite:", 32, 8, function() {
    var selection = GetSelection();
    switch (selection) {
        case 0: obj_emu_demo.data.sprite = spr_emu_demo_birb_yellow; break;
        case 1: obj_emu_demo.data.sprite = spr_emu_demo_birb_red; break;
        case 2: obj_emu_demo.data.sprite = spr_emu_demo_birb_blue; break;
    }
});
list_sprites.AddEntries(["Yellow Birb", "Red Birb", "Blue Birb"]);

var birb_button = new EmuButtonImage(320, 32, 256, 256, spr_emu_demo_birb_solo, 0, c_white, 1, true, function() {
    var dialog = new EmuDialog(256, 128, "Birb!");
    dialog.AddContent([
        new EmuText(32, EMU_AUTO, 192, 64, "[fa_center][wave][rainbow]Birb!"),
        new EmuButton(dialog.width / 2 - 128 / 2, dialog.height - 32 - 32 / 2, 128, 32, "Close", emu_dialog_close_auto),
    ]);
});

tab_look.AddContent([
    list_sprites,
    birb_button,
]);
#endregion

#region stats

var input_str = new EmuInput(32, EMU_AUTO, 512, 32, "Strength:", string(data.str), "-5 to +5", 2, E_InputTypes.INT, function() {
    obj_emu_demo.data.str = real(value);
});
input_str.SetRealNumberBounds(-5, 5);
var input_dex = new EmuInput(32, EMU_AUTO, 512, 32, "Dexterity:", string(data.dex), "-5 to +5", 2, E_InputTypes.INT, function() {
    obj_emu_demo.data.str = real(value);
});
input_dex.SetRealNumberBounds(-5, 5);
var input_con = new EmuInput(32, EMU_AUTO, 512, 32, "Constitution:", string(data.con), "-5 to +5", 2, E_InputTypes.INT, function() {
    obj_emu_demo.data.con = real(value);
});
input_con.SetRealNumberBounds(-5, 5);
var input_int = new EmuInput(32, EMU_AUTO, 512, 32, "Intelligence:", string(data.int), "-5 to +5", 2, E_InputTypes.INT, function() {
    obj_emu_demo.data.int = real(value);
});
input_int.SetRealNumberBounds(-5, 5);
var input_wis = new EmuInput(32, EMU_AUTO, 512, 32, "Wisdom:", string(data.wis), "-5 to +5", 2, E_InputTypes.INT, function() {
    obj_emu_demo.data.wis = real(value);
});
input_wis.SetRealNumberBounds(-5, 5);
var input_cha = new EmuInput(32, EMU_AUTO, 512, 32, "Charisma:", string(data.cha), "-5 to +5", 2, E_InputTypes.INT, function() {
    obj_emu_demo.data.cha = real(value);
});
input_cha.SetRealNumberBounds(-5, 5);
var input_level = new EmuInput(32, EMU_AUTO, 512, 32, "[#006600]Level:[/c]", string(data.level), "1 to 10", 2, E_InputTypes.INT, function() {
    obj_emu_demo.data.level = real(value);
});
input_level.SetRealNumberBounds(1, 10);
tab_stats.AddContent([
    new EmuText(32, EMU_AUTO, 512, 32, "[c_blue]Character Stats[/c]"),
    input_str,
    input_dex,
    input_con,
    input_int,
    input_wis,
    input_cha,
    input_level,
]);
#endregion

#region skills
tab_skills.AddContent(new EmuText(32, EMU_AUTO, 512, 32, "[c_blue]Skills[/c]"));

var list_your_skills = new EmuList(32, EMU_AUTO, 256, 32, "Your skills:", 32, 12, function() {
    var selection = GetSelection();
    if (selection > -1) {
        name.SetValue(obj_emu_demo.data.skills[| selection]);
    }
});
list_your_skills.SetList(data.skills);
tab_skills.AddContent(list_your_skills);

var button_add = new EmuButton(320, list_your_skills.y, 256, 32, "Add Skill", function() {
    ds_list_add(obj_emu_demo.data.skills, "Skill " + string(ds_list_size(obj_emu_demo.data.skills)));
});
var button_remove = new EmuButton(320, EMU_AUTO, 256, 32, "Remove Skill", function() {
    var selection = list.GetSelection();
    if (selection > -1) {
        ds_list_delete(obj_emu_demo.data.skills, selection);
    }
});
tab_skills.AddContent([
    button_add,
    button_remove,
    new EmuText(320, EMU_AUTO, 256, 32, "Skill Name:"),
]);

var input_skill_name = new EmuInput(320, EMU_AUTO, 256, 32, "", "", "skill name", 32, E_InputTypes.STRING, function() {
    var selection = list.GetSelection();
    if (selection > -1) {
        obj_emu_demo.data.skills[| selection] = value;
    }
});
input_skill_name.SetInputBoxPosition(0, 0, 256, 32);

tab_skills.AddContent(input_skill_name);

list_your_skills.name = input_skill_name;
input_skill_name.list = list_your_skills;

button_add.list = list_your_skills;
button_remove.list = list_your_skills;
#endregion

#region summary
var input_summary = new EmuInput(32, EMU_AUTO, 512, 256, "Summary:", data.summary, "up to 500 characters", 500, E_InputTypes.STRING, function() {
    obj_emu_demo.data.summary = value;
});
input_summary.SetMultiLine(true);
input_summary.SetInputBoxPosition(160, 0, 512, 256);

tab_summary.AddContent([
    new EmuText(32, EMU_AUTO, 512, 32, "[c_blue]Summary[/c]"),
    input_summary,
]);
#endregion

#region overview and credits
container.AddContent([
    new EmuButton(704, 32, 256, 32, "Show Character Summary", function() {
        var dialog = new EmuDialog(640, 384, "Character Summary");
        var demo = obj_emu_demo;
        var pronouns_possessive = ["Their", "His", "Her"];
        var pronoun_possessive = pronouns_possessive[demo.data.pronouns];
        var pronouns_subject = ["They", "He", "She"];
        var pronoun_subject = pronouns_subject[demo.data.pronouns];
        var pronouns_verb = ["are", "is", "is"];
        var pronoun_verb = pronouns_verb[demo.data.pronouns];
        var skill_count = ds_list_size(demo.data.skills);
        var calc_stat = function(base) {
            return 2 * base + 10;
        }
        
        var str_summary = "[rainbow][wave]" + demo.data.name + "[/wave][/rainbow] (or [rainbow][wave]" + demo.data.nickname + ",[/wave][/rainbow] according to " +
            string_lower(pronoun_possessive) + " friends) is a " + demo.all_alignments[| demo.data.alignment] + " duckling from " + demo.all_hometowns[| demo.data.hometown] + ". " +
            pronoun_subject + " " + pronoun_verb + " Level " + string(demo.data.level) + " with [c_red]" + string(calc_stat(demo.data.str)) + "[/c] Strength, [c_red]" +
            string(calc_stat(demo.data.dex)) + "[/c] Dexterity, [c_red]" + string(calc_stat(demo.data.con)) + "[/c] Constitution, [c_red]" + string(calc_stat(demo.data.int)) +
            "[/c] Intelligence, [c_red]" + string(calc_stat(demo.data.wis)) + "[/c] Wisdom, and [c_red]" + string(calc_stat(demo.data.cha)) + "[/c] Charisma. " + pronoun_subject +
            " know" + ((demo.data.pronouns != 0) ? "s" : "") + " [c_blue]" + string(skill_count) + "[/c] skill" + ((skill_count == 1) ? "" : "s");
        if (skill_count > 0) {
            if (skill_count > 3) {
                str_summary += ", including ";
            } else {
                str_summary += ": ";
            }
            switch (skill_count) {
                case 1: str_summary += demo.data.skills[| 0]; break;
                case 2: str_summary += demo.data.skills[| 0] + " and " + demo.data.skills[| 1]; break;
                default: str_summary += demo.data.skills[| 0] + ", " + demo.data.skills[| 1] + " and " + demo.data.skills[| 2]; break;
            }
        }
        str_summary += ".\n\n[#006600]" + demo.data.summary + "[/rainbow]";
        
        dialog.AddContent([
            new EmuText(32, EMU_AUTO, 560, 320, str_summary),
            new EmuButton(dialog.width / 2 - 128 / 2, dialog.height - 32 - 32 / 2, 128, 32, "Close", emu_dialog_close_auto),
        ]);
    }),
    new EmuButton(704, EMU_AUTO, 256, 32, "Credits", function() {
        var dialog = new EmuDialog(640, 320, "Credits");
        dialog.AddContent([
            new EmuText(dialog.width / 2, EMU_AUTO, 560, 64, "[c_blue][fa_center]Emu UI, a user interface framework for GameMaker Studio 2.3 written by @dragonitespam[/c]"),
            new EmuText(32, EMU_AUTO, 560, 32, "The [rainbow][wave]Scribble[/wave][/rainbow]  text renderer is by @jujuadams"),
            new EmuText(32, EMU_AUTO, 560, 32, "Models are from Kenney's Nature Kit (www.kenney.nl)"),
            new EmuText(32, EMU_AUTO, 560, 32, "Emu iconography by @gart_gh"),
            new EmuText(32, EMU_AUTO, 560, 32, "Duckling sprite by @AleMunin"),
            new EmuButton(dialog.width / 2 - 128 / 2, dialog.height - 32 - 32 / 2, 128, 32, "Close", emu_dialog_close_auto),
        ]);
    }),
]);
#endregion

#region render _surface
container.AddContent(
    new EmuRenderSurface(704, 144, 540, 400,
        function(mx, my) { scene.Render(); },
        function(mx, my) { scene.Control(); },
        function() { scene = new EmuDemoMeshScene(); },
        function() { scene.Destroy(); }
    )
);
#endregion
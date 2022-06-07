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
    skills: [],
    // summary
    summary: choose("Likes bacon, lettuce and tomatoes.", "Once walked a tightrope between the Twin Towers. Nearly won a Darwin Award.", "Actually dreams in code.", "Has a pet Mimic named Douglas the Dingbat.", "Always plays as a Nord.", "Grew up believing in Santa Claus."),
    favorite_color: make_colour_hsv(irandom(255), 255, 255),
};

all_hometowns = ["Alcamoth", "Hogwarts", "Markarth", "Mordor", "Narnia", "New Bark", "The Shire", "Wyoming", "Zanarkand"];
all_alignments = ["Lawful Good", "Lawful Neutral", "Lawful Evil", "Neutral Good", "Boring", "Neutral Evil", "Chaotic Good", "Chaotic Neutral", "Chaotic Evil"];

container = new EmuCore(32, 32, 640, 640, "main");

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
    new EmuText(32, EMU_AUTO, 512, 32, "[c_aqua]Character Bio[/c]"),
    new EmuInput(32, EMU_AUTO, 512, 32, "Name:", data.name, "enter a name", 32, E_InputTypes.STRING, function() {
        obj_emu_demo.data.name = self.value;
    }),
    new EmuInput(32, EMU_AUTO, 512, 32, "Nickname:", self.data.nickname, "enter a nickname", 32, E_InputTypes.STRING, function() {
        obj_emu_demo.data.nickname = self.value;
    }),
    new EmuRadioArray(32, EMU_AUTO, 512, 32, "Pronouns:", self.data.pronouns, function() {
        obj_emu_demo.data.pronouns = self.value;
    })
        .AddOptions(["They/them", "He/him", "She/her"])
        .SetColumns(1, 160),
    new EmuList(32, EMU_AUTO, 256, 32, "Hometown:", 32, 0, function() {
        var selection = self.GetSelection();
        if (selection > -1) {
            obj_emu_demo.data.hometown = selection;
        }
    })
        .SetList(self.all_hometowns)
        .Select(self.data.hometown, true)
        .FitToBox(/* default argument */, 288),
    new EmuList(320, EMU_INLINE, 256, 32, "Alignment:", 32, 8, function() {
        var selection = self.GetSelection();
        if (selection > -1) {
            obj_emu_demo.data.alignment = selection;
        }
    })
        .SetList(self.all_alignments)
        .Select(self.data.alignment, true)
]);
#endregion

#region appearance
tab_look.AddContent([
    new EmuText(32, EMU_AUTO, 256, 32, "[c_aqua]Visual Appearance[/c]"),
    new EmuText(32, EMU_AUTO, 256, 32, "Size:"),
    new EmuProgressBar(32, EMU_AUTO, 256, 32, 12, 0.4, 1, true, self.data.size, function() {
        obj_emu_demo.data.size = self.value;
    }),
    new EmuList(32, EMU_AUTO, 256, 32, "Sprite:", 32, 8, function() {
        var selection = GetSelection();
        switch (selection) {
            case 0: obj_emu_demo.data.sprite = spr_emu_demo_birb_yellow; break;
            case 1: obj_emu_demo.data.sprite = spr_emu_demo_birb_red; break;
            case 2: obj_emu_demo.data.sprite = spr_emu_demo_birb_blue; break;
        }
    })
        .AddEntries(["Yellow Birb", "Red Birb", "Blue Birb"]),
    new EmuColorPicker(32, EMU_AUTO, 256, 32, "Color:", self.data.favorite_color, function() {
        obj_emu_demo.data.favorite_color = value;
    }),
    new EmuButtonImage(320, 32, 256, 256, spr_emu_demo_birb_solo, 0, c_white, 1, true, function() {
        var dialog = new EmuDialog(256, 128, "Birb!");
        dialog.AddContent([
            new EmuText(32, EMU_AUTO, 192, 64, "[fa_center][wave][rainbow]Birb!"),
            new EmuButton(dialog.width / 2 - 128 / 2, dialog.height - 32 - 32 / 2, 128, 32, "Close", emu_dialog_close_auto),
        ]);
    }),
]);
#endregion

#region stats
tab_stats.AddContent([
    new EmuText(32, EMU_AUTO, 512, 32, "[c_aqua]Character Stats"),
    new EmuInput(32, EMU_AUTO, 512, 32, "Strength:", string(self.data.str), "-5 to -5", 2, E_InputTypes.INT, function() {
            obj_emu_demo.data.str = real(self.value);
        })
        .SetRealNumberBounds(-5, 5),
    new EmuInput(32, EMU_AUTO, 512, 32, "Dexterity:", string(self.data.dex), "-5 to -5", 2, E_InputTypes.INT, function() {
            obj_emu_demo.data.dex = real(self.value);
        })
        .SetRealNumberBounds(-5, 5),
    new EmuInput(32, EMU_AUTO, 512, 32, "Constitution:", string(self.data.con), "-5 to -5", 2, E_InputTypes.INT, function() {
            obj_emu_demo.data.con = real(self.value);
        })
        .SetRealNumberBounds(-5, 5),
    new EmuInput(32, EMU_AUTO, 512, 32, "Intelligence:", string(self.data.int), "-5 to -5", 2, E_InputTypes.INT, function() {
            obj_emu_demo.data.int = real(self.value);
        })
        .SetRealNumberBounds(-5, 5),
    new EmuInput(32, EMU_AUTO, 512, 32, "Wisdom:", string(self.data.wis), "-5 to -5", 2, E_InputTypes.INT, function() {
            obj_emu_demo.data.wis = real(self.value);
        })
        .SetRealNumberBounds(-5, 5),
    new EmuInput(32, EMU_AUTO, 512, 32, "Charisma:", string(self.data.cha), "-5 to -5", 2, E_InputTypes.INT, function() {
            obj_emu_demo.data.cha = real(self.value);
        })
        .SetRealNumberBounds(-5, 5),
    new EmuInput(32, EMU_AUTO, 512, 32, "[c_lime]Level:", string(self.data.level), "1 to 10", 2, E_InputTypes.INT, function() {
            obj_emu_demo.data.level = real(self.value);
        })
        .SetRealNumberBounds(1, 10),
]);
#endregion

#region skills
tab_skills.AddContent([
    new EmuText(32, EMU_AUTO, 512, 32, "[c_aqua]Skills[/c]"),
    new EmuList(32, EMU_AUTO, 256, 32, "Your skills:", 32, 12, function() {
        var selection = self.GetSelection();
        if (selection > -1) {
            self.GetSibling("SkillName").SetValue(obj_emu_demo.data.skills[selection]);
        }
    })
        .SetID("SkillList")
        .SetList(self.data.skills)
        .AddContent(self.data.skills),
    new EmuButton(320, EMU_INLINE, 256, 32, "Add Skill", function() {
        array_push(obj_emu_demo.data.skills, "Skill " + string(array_length(obj_emu_demo.data.skills)));
    }),
    new EmuButton(320, EMU_AUTO, 256, 32, "Remove Skill", function() {
        var selection = self.GetSibling("SkillList").GetSelection();
        if (selection > -1) {
            array_delete(obj_emu_demo.data.skills, selection, 1);
        }
    }),
    new EmuText(320, EMU_AUTO, 256, 32, "Skill Name:"),
    new EmuInput(320, EMU_AUTO, 256, 32, "", "", "skill name", 32, E_InputTypes.STRING, function() {
        var selection = self.GetSibling("SkillList").GetSelection();
        if (selection > -1) {
            obj_emu_demo.data.skills[selection] = self.value;
        }
    })
        .SetID("SkillName")
        .SetInputBoxPosition(0, 0, 256, 32)
]);
#endregion

#region summary
tab_summary.AddContent([
    new EmuText(32, EMU_AUTO, 512, 32, "[c_aqua]Summary[/c]"),
    new EmuInput(32, EMU_AUTO, 512, 256, "Summary:", self.data.summary, "up to 500 characters", 500, E_InputTypes.STRING, function() {
        obj_emu_demo.data.summary = self.value;
    })
        .SetMultiLine(true)
        .SetInputBoxPosition(160, 0, 512, 256),
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
        var skill_count = array_length(demo.data.skills);
        var calc_stat = function(base) {
            return 2 * base + 10;
        }
        
        var str_fav_color = emu_string_hex(colour_get_red(demo.data.favorite_color), 2) + emu_string_hex(colour_get_green(demo.data.favorite_color), 2) +
            emu_string_hex(colour_get_blue(demo.data.favorite_color), 2);
        
        var str_summary = "[rainbow][wave]" + demo.data.name + "[/wave][/rainbow] (or [rainbow][wave]" + demo.data.nickname + ",[/wave][/rainbow] according to " +
            string_lower(pronoun_possessive) + " friends) is a " + demo.all_alignments[demo.data.alignment] + " duckling from " + demo.all_hometowns[demo.data.hometown] + ". " +
            pronoun_subject + " " + pronoun_verb + " Level " + string(demo.data.level) + " with [c_orange]" + string(calc_stat(demo.data.str)) + "[/c] Strength, [c_orange]" +
            string(calc_stat(demo.data.dex)) + "[/c] Dexterity, [c_orange]" + string(calc_stat(demo.data.con)) + "[/c] Constitution, [c_orange]" + string(calc_stat(demo.data.int)) +
            "[/c] Intelligence, [c_orange]" + string(calc_stat(demo.data.wis)) + "[/c] Wisdom, and [c_orange]" + string(calc_stat(demo.data.cha)) + "[/c] Charisma. " + pronoun_subject +
            " know" + ((demo.data.pronouns != 0) ? "s" : "") + " [c_aqua]" + string(skill_count) + "[/c] skill" + ((skill_count == 1) ? "" : "s") + ". " + pronoun_possessive +
            " favorite color is [#" + str_fav_color + "]0x" + str_fav_color + "[/c]";
        if (skill_count > 0) {
            if (skill_count > 3) {
                str_summary += ", including ";
            } else {
                str_summary += ": ";
            }
            switch (skill_count) {
                case 1: str_summary += demo.data.skills[0]; break;
                case 2: str_summary += demo.data.skills[0] + " and " + demo.data.skills[1]; break;
                default: str_summary += demo.data.skills[0] + ", " + demo.data.skills[1] + " and " + demo.data.skills[2]; break;
            }
        }
        str_summary += ".\n\n[c_lime]" + demo.data.summary;
        
        dialog.AddContent([
            new EmuText(32, EMU_AUTO, 560, 320, str_summary),
            new EmuButton(dialog.width / 2 - 128 / 2, dialog.height - 32 - 32 / 2, 128, 32, "Close", emu_dialog_close_auto),
        ]);
    }),
    new EmuButton(704, EMU_AUTO, 256, 32, "Credits", function() {
        var dialog = new EmuDialog(640, 320, "Credits");
        dialog.AddContent([
            new EmuText(dialog.width / 2, EMU_AUTO, 560, 64, "[c_aqua][fa_center]Emu UI, a user interface framework for GameMaker Studio 2.3 written by @dragonitespam[/c]"),
            new EmuText(32, EMU_AUTO, 560, 32, "The [rainbow][wave]Scribble[/wave][/rainbow] text renderer is by @jujuadams"),
            new EmuText(32, EMU_AUTO, 560, 32, "Models are from Kenney's Nature Kit (www.kenney.nl)"),
            new EmuText(32, EMU_AUTO, 560, 32, "Emu iconography by @gart_gh"),
            new EmuText(32, EMU_AUTO, 560, 32, "Duckling sprite by @AleMunin"),
            new EmuButton(dialog.width / 2 - 128 / 2, dialog.height - 32 - 32 / 2, 128, 32, "Close", emu_dialog_close_auto),
        ]);
    }),
]);
#endregion

#region render window
container.AddContent(
    new EmuRenderSurface(704, 144, 540, 400,
        function(mx, my) { self.scene.Render(); },
        function(mx, my) { self.scene.Control(); },
        function() { self.scene = new EmuDemoMeshScene(); }
    )
);
#endregion
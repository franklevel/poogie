/*
* Copyright (c) 2017 franklevel
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
*/
namespace Poogie { 
    public class MainWindow : Gtk.Dialog {
        //public Gtk.HeaderBar headerbar;
        public Gtk.Label label_info;
        public Gtk.Stack stack;
        public Gtk.Label label_result;
        public Gtk.Button button_generate;
        public Gtk.Box box_options;
        public Gtk.RadioButton button_numeric;
        public Gtk.RadioButton button_alphanumeric;
        public Gtk.RadioButton button_special;
        public Gtk.RadioButton button_hackertype;
        public Gtk.Scale scale_size;
        public static int size = 8;
        public static string charset = "alphanumeric";
        

        private void toggled (Gtk.ToggleButton button) {
            string option = button.label;
            MainWindow.charset = option.down();
            this.show_result();
            stdout.printf ("Chosen %s - Password: %s\n", option.down(), MainWindow.generate());
        }

        public MainWindow (Gtk.Application application) {
            GLib.Object (application: application,
                        icon_name: "com.github.franklevel.poogie",
                        resizable: false,
                        title: _("Poogie"),
                        height_request: 380,
                        width_request: 440,
                        border_width: 10,
                        window_position: Gtk.WindowPosition.CENTER
            );
        }

        construct {
            
            /*
            headerbar = new Gtk.HeaderBar ();
            headerbar.show_close_button = true;
            headerbar.set_title ("Poogie");
            headerbar.has_subtitle = false;
            set_titlebar (headerbar);  
            */
            
            var provider = new Gtk.CssProvider ();
            try {
                provider.load_from_path ("../data/stylesheet.css");
                Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_USER);
            } catch (Error e){
                stderr.printf("Error: %s\n", e.message);
            }
           
            
            var grid = new Gtk.Grid ();
            grid.margin_top = 0;
            grid.column_homogeneous = true;
            grid.column_spacing = 6;
            grid.row_spacing = 6;

            label_result = new Gtk.Label (MainWindow.generate());            
            label_result.hexpand = true;
            label_result.selectable = true;
            label_result.set_width_chars (32);
            label_result.get_style_context().add_class("bigfont");
            
            // Copy to clipboard            
            label_result.copy_clipboard.connect (() => {
                stdout.printf("Label result was clicked!");
            });
            
                
            button_generate = new Gtk.Button.with_label (_("Generate"));      
            button_generate.hexpand = true;

            button_alphanumeric = new Gtk.RadioButton.with_label_from_widget (null, _("Alphanumeric"));
            button_alphanumeric.toggled.connect (toggled);
   
            button_numeric = new Gtk.RadioButton.with_label_from_widget (button_alphanumeric, _("Numeric"));
            button_numeric.toggled.connect (toggled);
       
            button_special = new Gtk.RadioButton.with_label_from_widget (button_alphanumeric, _("Special"));
            button_special.toggled.connect (toggled);
    
            button_hackertype = new Gtk.RadioButton.with_label_from_widget (button_alphanumeric, _("Hacker"));
            button_hackertype.toggled.connect (toggled);
    
           
            /* Box Options */
            box_options = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            box_options.pack_start (button_alphanumeric, false , false, 0);
            box_options.pack_start (button_numeric, false , false, 0);
            box_options.pack_start (button_special, false , false, 0);
            box_options.pack_start (button_hackertype, false , false, 0);

            /* Password Lenght */
            scale_size = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 8.0, 32.0, 1 );
            scale_size.set_digits (0);
            scale_size.add_mark (8, Gtk.PositionType.BOTTOM, null);
            scale_size.add_mark (12, Gtk.PositionType.BOTTOM, null);
            scale_size.add_mark (16, Gtk.PositionType.BOTTOM, null);
            scale_size.add_mark (20, Gtk.PositionType.BOTTOM, null);
            scale_size.add_mark (24, Gtk.PositionType.BOTTOM, null);
            scale_size.add_mark (28, Gtk.PositionType.BOTTOM, null);
            scale_size.add_mark (32, Gtk.PositionType.BOTTOM, null);
            scale_size.set_value_pos (Gtk.PositionType.BOTTOM);
            scale_size.set_valign (Gtk.Align.START);

            /* Attachments */
            grid.attach (label_info, 1, 4, 3, 2);
            grid.attach (label_result, 1, 8, 3, 2 );
            grid.attach (box_options, 1, 10, 3, 2);
            grid.attach (scale_size, 1, 12, 3, 2);
            grid.attach (button_generate, 1, 14, 3, 2 );            
                   
            /* Stack */
            stack = new Gtk.Stack ();
            stack.transition_type = Gtk.StackTransitionType.CROSSFADE;
            stack.margin = 6;
            stack.margin_top = 0;
            stack.homogeneous = true;
            stack.add_named (grid, "options");

            ((Gtk.Container) get_content_area ()).add (stack);
            stack.show_all ();

            // Button generator    
            button_generate.clicked.connect (() => {
               this.show_result ();
            }); 
            
            // Scale
            scale_size.value_changed.connect (() => {
                this.show_result();
                MainWindow.size = (int) scale_size.get_value();
                stdout.printf ("New size: %.0f\n", scale_size.get_value());
            });


        }
        
        public static string generate () {
            string letters = "abcdefghijklmnopqrstuvwxyz";
            string numbers = "0123456789";
            string alphanueric = "abcdefghijklmnopqrstuvwxyz0123456789";
            string random = "";
            string my_charset;
           
            if (MainWindow.charset.down() == "alphanumeric") {
                my_charset = alphanueric;
            } else if (MainWindow.charset.down() == "numeric") {
                my_charset = numbers;                
            } else if (MainWindow.charset.down() == "letters") {
                my_charset = letters;
            } else {
                my_charset = "abcdefghijklmnopqrstuvwxyz#!°~?_*/-+.,;:";
            }

            for (int i = 0; i < MainWindow.size; i++ ) {
                int r = Random.int_range(0, my_charset.length);
                string ch = my_charset.get_char(my_charset.index_of_nth_char(r)).to_string();
                random += ch;
            }

            return random;
            
        }

        public void show_result () {
            label_result.set_text (MainWindow.generate());
        }
    }
}
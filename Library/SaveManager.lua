local SaveManager = {};
SaveManager.Folder = "贪婪.贵宾";
SaveManager.Ignore = {};

SaveManager:SetLibrary(Menu);

SaveManager.Parser = {
   TextBox = {
       Save = function(idx, object)
           return {type = "TextBox", idx = idx, text = object.Value};
       end,
       Load = function(idx, data)
           if Menu.Options[idx] then
               Menu.Options[idx]:SetValue(data.text);
           end
       end
   },
   
   ComboBox = {
       Save = function(idx, object)
           return {type = "ComboBox", idx = idx, value = object.Value};
       end,
       Load = function(idx, data)  
           if Menu.Options[idx] then
               Menu.Options[idx]:SetValue(data.value);
           end
       end
   },

   CheckBox = {
       Save = function(idx, object)
           return {type = "CheckBox", idx = idx, value = object.Value};
       end, 
       Load = function(idx, data)
           if Menu.Options[idx] then
               Menu.Options[idx]:SetValue(data.value); 
           end
       end
   },

   ColorPicker = {
       Save = function(idx, object) 
           return {type = "ColorPicker", idx = idx, color = object.Color:ToHex()};
       end,
       Load = function(idx, data)
           if Menu.Options[idx] then
               Menu.Options[idx]:SetValue(Color3.fromHex(data.color));
           end
       end
   },

   Slider = {
       Save = function(idx, object)
           return {type = "Slider", idx = idx, value = tostring(object.Value)};
       end,
       Load = function(idx, data)
           if Menu.Options[idx] then
               Menu.Options[idx]:SetValue(tonumber(data.value));
           end
       end
   }
};

function SaveManager:Save(name)
   if not name then return false; end
   
   local config = {objects = {}};
   
   for idx, item in pairs(Menu.Options) do
       if self.Parser[item.Class] then
           table.insert(config.objects, self.Parser[item.Class].Save(idx, item));
       end
   end

   writefile(self.Folder .. "/configs/" .. name .. ".json", game:GetService("HttpService"):JSONEncode(config));
   
   return true;
end;

function SaveManager:Load(name)
   if not name then return false; end
   
   local file = readfile(self.Folder .. "/configs/" .. name .. ".json");
   local data = game:GetService("HttpService"):JSONDecode(file);
   
   for _, obj in pairs(data.objects) do
       if self.Parser[obj.type] then
           self.Parser[obj.type].Load(obj.idx, obj);
       end
   end
   
   return true;
end;

function SaveManager:BuildConfigSection(tab)
   local Container = Menu.Container("Settings", "Configuration", "Left");

   Menu.TextBox("Settings", "Configuration", "Config Name", "", function(name)
       self:Save(name);
   end);

   Menu.Button("Settings", "Configuration", "Save Config", function()
       Menu:Notify("Saved config successfully!", 3);
   end);

   Menu.Button("Settings", "Configuration", "Load Config", function()
       self:Load(ConfigName);
       Menu:Notify("Loaded config successfully!", 3); 
   end);
   
   Menu.Button("Settings", "Configuration", "Reset Config", function()
       delfile(self.Folder .. "/configs/" .. ConfigName .. ".json");
       Menu:Notify("Reset config successfully!", 3);
   end);
end;

local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/greedgreedgreedgreed/greed.vip/refs/heads/main/Library/SaveManager.lua"))();

SaveManager:SetLibrary(Menu);
SaveManager:SetFolder("贪婪.贵宾");
SaveManager:BuildConfigSection(SettingsTab);
SaveManager:LoadAutoloadConfig();

return SaveManager;

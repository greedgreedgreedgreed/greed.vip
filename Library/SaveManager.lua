function SaveManager:BuildConfigSection(tab)
   if not tab or not tab.Name then return end;
   
   local Container = Menu.Container(tab.Name, "Configuration", "Left");
   if not Container then return end;

   Menu.TextBox(tab.Name, "Configuration", "Config Name", "", function(value) 
       SaveName = value;
   end);

   Menu.ComboBox(tab.Name, "Configuration", "Config List", nil, self:RefreshConfigList(), function(config)
       ConfigName = config;
   end);

   Menu.Button(tab.Name, "Configuration", "Create Config", function()
       if SaveName and SaveName:gsub(" ","") ~= "" then
           self:Save(SaveName);
           Menu:FindItem(tab.Name, "Configuration", "ComboBox", "Config List"):SetValue(nil, self:RefreshConfigList());
           Notifications:New("Created config: " .. SaveName, 5, MainColor);
       end
   end);

   Menu.Button(tab.Name, "Configuration", "Load Config", function()
       if ConfigName then
           self:Load(ConfigName);
           Notifications:New("Loaded config: " .. ConfigName, 5, MainColor);
       end
   end);

   Menu.Button(tab.Name, "Configuration", "Overwrite Config", function()
       if ConfigName then
           self:Save(ConfigName); 
           Notifications:New("Overwrote config: " .. ConfigName, 5, MainColor);
       end
   end);
   
   Menu.Button(tab.Name, "Configuration", "Delete Config", function()
       if ConfigName then
           delfile(self.Folder .. "/configs/" .. ConfigName .. ".json");
           Menu:FindItem(tab.Name, "Configuration", "ComboBox", "Config List"):SetValue(nil, self:RefreshConfigList());
           Notifications:New("Deleted config: " .. ConfigName, 5, MainColor);
       end
   end);

   Menu.Button(tab.Name, "Configuration", "Refresh List", function()
       Menu:FindItem(tab.Name, "Configuration", "ComboBox", "Config List"):SetValue(nil, self:RefreshConfigList());
       Notifications:New("Refreshed config list", 5, MainColor);
   end);

   Menu.Button(tab.Name, "Configuration", "Set Auto Load", function()
       if ConfigName then
           writefile(self.Folder .. "/autoload.txt", ConfigName);
           Notifications:New("Set auto load: " .. ConfigName, 5, MainColor);
       end
   end);

   Menu.Button(tab.Name, "Configuration", "Clear Auto Load", function()
       if isfile(self.Folder .. "/autoload.txt") then
           delfile(self.Folder .. "/autoload.txt");
           Notifications:New("Cleared auto load config", 5, MainColor);
       end
   end);
end;

function SaveManager:LoadAutoloadConfig()
   if isfile(self.Folder .. "/autoload.txt") then
       local name = readfile(self.Folder .. "/autoload.txt");
       local success = self:Load(name);
       
       if success then
           Notifications:New("Auto-loaded config: " .. name, 5, MainColor);
       end
   end
end;

function SaveManager:SetFolder(folder)
   self.Folder = folder;
   self:BuildFolderTree();
end;

function SaveManager:SetLibrary(library)
   self.Library = library;
end;

function SaveManager:RefreshConfigList()
   self:BuildFolderTree();
   local list = listfiles(self.Folder .. "/configs");

   local out = {};
   for i = 1, #list do
       local file = list[i];
       if file:sub(-5) == '.json' then
           local pos = file:find('.json', 1, true);
           local start = pos;

           local char = file:sub(pos, pos);
           while char ~= '/' and char ~= '\\' and char ~= '' do
               pos = pos - 1;
               char = file:sub(pos, pos);
           end

           if char == '/' or char == '\\' then
               table.insert(out, file:sub(pos + 1, start - 1));
           end
       end
   end
   
   return out;
end;

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

function SaveManager:BuildFolderTree()
   local paths = {
       self.Folder,
       self.Folder .. "/configs"
   };

   for i = 1, #paths do
       local str = paths[i];
       if not isfolder(str) then
           makefolder(str);
       end
   end
end;

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

return SaveManager;

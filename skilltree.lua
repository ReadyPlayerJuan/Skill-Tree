
SkillTree = {}

function SkillTree:new()
  local t = setmetatable({}, { __index = SkillTree })
  
  t.width = 0
  t.height = 0
  t.total_points = 0
  t.points_available = 0
  t.skills = {}
  

  t.window = Cyclone.Window:new()
  t.window.name = "Skills"
  Cyclone.wmclient.registerWindow(t.window)
  t:render()
  
  Cyclone.wmclient.registerEvent(t.window,"button",function(id,name)
    t:buttonPressed(id, name)
  end)
  
  return t
end

function SkillTree:addPoint()
  self:addPoints(1)
end

function SkillTree:addPoints(num)
  self.total_points = self.total_points + num
  self.points_available = self.points_available + num
  
  self:refresh()
end

function SkillTree:resetPoints()
  for i, _skill in ipairs(self.skills) do
    _skill:resetLevel()
  end
  
  self.points_available = self.total_points
  self:refresh()
end

function SkillTree:refresh()
  for i, _skill in ipairs(self.skills) do
    --loop through and update skills
    --Cyclone.terminal.write("updating "..i.." ".._skill.name)
    
    _skill.skill_available = false
    if(#_skill.parents == 0 or _skill.current_level == _skill.num_levels) then
      _skill.skill_available = true
    elseif(#_skill.parents > 0) then
      _skill.skill_available = true
      for i, parent in ipairs(_skill.parents) do
        if(parent.current_level ~= parent.num_levels) then
          _skill.skill_available = false
        end
      end
    end
    if(self.points_available > 0) then
      _skill.skill_point_available = true
    else
      _skill.skill_point_available = false
    end
    
    _skill:refresh()
    
    --Cyclone.terminal.write(_skill.name.." available: "..tostring(_skill.skill_available))
  end
  
  self:render()
end

function SkillTree:render()
  local _SKILL_SIZE = 22
  local _SKILL_SCALE = 2
  local _BUTTON_BORDER = 2
  local _SKILL_BORDER_X = 8
  local _SKILL_BORDER_Y = 20
  local _WINDOW_BORDER = 12
  local _SKILL_LEVEL_TEXT_HEIGHT = 10
  local _RELATION_LINE_TOP_X_OFFSET = 16
  local _RELATION_LINE_TOP_Y_OFFSET = 4
  local _RELATION_LINE_CENTER_Y_OFFSET = 4
  local _RELATION_LINE_BOTTOM_Y_OFFSET = 4
  local _NUMBER_BOX_WIDTH = 24
  local _NUMBER_BOX_HEIGHT = 12
  local _NUMBER_BOX_Y_OFFSET = 4
  local _TEXT_X_OFFSET = 2
  local _TEXT_Y_OFFSET = -1
  --local icon = Sprite.load("cycloneitems","items.png", 1,8,8)
  --window.icon = icon
  
  self.window:clear()
  
  for i, _skill in ipairs(self.skills) do
    --loop through and draw skills
    --Cyclone.terminal.write("drawing "..name)
    local _grid_x = _skill.icon_x
    local _grid_y = _skill.icon_y
    
		local _button = Cyclone.Button:new()
    _skill.button = _button
		_button.id = _skill.name
		_button.spacing_x = _SKILL_SIZE + _BUTTON_BORDER
		_button.spacing_y = _SKILL_SIZE + _BUTTON_BORDER
		_button.x = _grid_x * _SKILL_SCALE * (_SKILL_SIZE + _SKILL_BORDER_X) + _WINDOW_BORDER - _BUTTON_BORDER
		_button.y = _grid_y * _SKILL_SCALE * (_SKILL_SIZE + _SKILL_BORDER_Y) + _WINDOW_BORDER - _BUTTON_BORDER
    local _button_size = (_SKILL_SIZE + _BUTTON_BORDER) * _SKILL_SCALE
    
		local _itemdrawfunction = function()
      
      --DRAW ICON: set colors
      local _inner_text_color, _outer_text_color, _image_shade_alpha
      if(_skill.skill_available) then
        if(_skill.current_level == _skill.num_levels) then
          --max leveled skill
          _inner_text_color = Color.LIGHT_GREEN
          _outer_text_color = Color.DARK_GREEN
          
          if(_skill.hover_frame_count == 0) then
            _image_shade_alpha = 0.1
          else
            _image_shade_alpha = 0.0
          end
        else
          --skill available to be upgraded
          _inner_text_color = Color.WHITE
          _outer_text_color = Color.BLACK
          
          if(_skill.hover_frame_count == 0) then
            _image_shade_alpha = 0.1
          else
            _image_shade_alpha = 0.0
          end
        end
      else
        --unavailable skill
        _inner_text_color = Color.LIGHT_RED
        _outer_text_color = Color.DARK_RED
        
        if(_skill.hover_frame_count == 0) then
          _image_shade_alpha = 0.6
        else
          _image_shade_alpha = 0.25
        end
      end
      
      
      --DRAW ICON: draw relationship lines to children
      for i, child in ipairs(_skill.children) do
        if(child.button) then
          local _start_x = _button.x + _button_size / 2 + (i - 1 - ((#_skill.children - 1) / 2)) * _RELATION_LINE_TOP_X_OFFSET
          local _start_y = _button.y + _button_size - _RELATION_LINE_TOP_Y_OFFSET
          local _end_x = child.button.x + _button_size / 2
          local _end_y = child.button.y + _RELATION_LINE_BOTTOM_Y_OFFSET
          local _center_y = ((_start_y + _end_y) / 2) + _RELATION_LINE_CENTER_Y_OFFSET
          
          if(not child.skill_available) then
            graphics.color(Color.darken(self.window.body_color, 0.08))
          else
            graphics.color(Color.darken(self.window.body_color, 0.15))
          end
          graphics.line(_start_x, _start_y, _start_x, _center_y, 5)
          graphics.line(_start_x, _center_y, _end_x, _center_y, 5)
          graphics.line(_end_x, _center_y, _end_x, _end_y, 5)
          
          if(not child.skill_available) then
            graphics.color(Color.darken(self.window.body_color, 0.15))
          else
            graphics.color(Color.darken(self.window.body_color, 0.4))
          end
          graphics.line(_start_x, _start_y, _start_x, _center_y, 3)
          graphics.line(_start_x, _center_y, _end_x, _center_y, 3)
          graphics.line(_end_x, _center_y, _end_x, _end_y, 3)
        end
      end
      
      
      --DRAW ICON: draw the actual icon and shade out if unavailable
      graphics.color(Color.WHITE)
      graphics.alpha(1)
      graphics.drawImage{
        image = _skill.icon,
        x = _button.x + _button_size / 2,
        y = _button.y + _button_size / 2,
        xscale = _SKILL_SCALE,
        yscale = _SKILL_SCALE,
      }
      if(_image_shade_alpha > 0) then
        graphics.alpha(_image_shade_alpha)
        graphics.color(Color.BLACK)
        graphics.rectangle(_button.x, _button.y, _button.x + (_SKILL_SIZE + _BUTTON_BORDER) * 2, _button.y + (_SKILL_SIZE + _BUTTON_BORDER) * 2, false)
        graphics.alpha(1)
      end
      
      --DRAW ICON: draw level text box
      local _font_x = _button.x + _button_size / 2
      local _font_y = _button.y + _button_size + _TEXT_Y_OFFSET
      graphics.color(Color.darken(self.window.body_color, 0.3))
      graphics.rectangle(_font_x - _NUMBER_BOX_WIDTH/2 - 1, _font_y - _NUMBER_BOX_HEIGHT/2 - 1 + _NUMBER_BOX_Y_OFFSET,
          _font_x + _NUMBER_BOX_WIDTH/2 + 1, _font_y + _NUMBER_BOX_HEIGHT/2 + 1 + _NUMBER_BOX_Y_OFFSET, false)
      graphics.color(self.window.body_color)
      graphics.rectangle(_font_x - _NUMBER_BOX_WIDTH/2, _font_y - _NUMBER_BOX_HEIGHT/2 + _NUMBER_BOX_Y_OFFSET,
          _font_x + _NUMBER_BOX_WIDTH/2, _font_y + _NUMBER_BOX_HEIGHT/2 + _NUMBER_BOX_Y_OFFSET, false)
      
      
      --DRAW ICON: draw level text
      graphics.color(_outer_text_color)
      for _x = _font_x - 1, _font_x + 1 do
        for _y = _font_y - 1, _font_y + 1 do
          graphics.print(
            (_skill.current_level.."/".._skill.num_levels),
            _x + _TEXT_X_OFFSET,
            _y,
            graphics.FONT_DEFAULT,
            graphics.ALIGN_MIDDLE,
            graphics.ALIGN_TOP
          )
        end
      end
      graphics.color(_inner_text_color)
      graphics.print(
        (_skill.current_level.."/".._skill.num_levels),
        _font_x + _TEXT_X_OFFSET,
        _font_y,
        graphics.FONT_DEFAULT,
        graphics.ALIGN_MIDDLE,
        graphics.ALIGN_TOP
      )
		end
		self.window:addElement(_button)
		self.window:addElement(_itemdrawfunction)
  end
  
  local _width = (_SKILL_SIZE + _SKILL_BORDER_X) * _SKILL_SCALE * self.width - 2*_SKILL_BORDER_X + _WINDOW_BORDER * 2
  local _height = (_SKILL_SIZE + _SKILL_BORDER_Y) * _SKILL_SCALE * self.height - 2*_SKILL_BORDER_Y + _WINDOW_BORDER * 2 + _SKILL_LEVEL_TEXT_HEIGHT
  self.window:resize(_width, _height)
end

function SkillTree:addSkill(skill)
  self.skills[#self.skills + 1] = skill
  if(skill.icon_x+1 > self.width) then self.width = skill.icon_x+1 end
  if(skill.icon_y+1 > self.height) then self.height = skill.icon_y+1 end
end

function SkillTree:buttonPressed(id, name)
  if(self.points_available > 0) then
    for i, _skill in ipairs(self.skills) do
      --Cyclone.terminal.write(id.." ".._skill.name.." "..tostring(_skill.skill_available))
      if _skill.name == id and _skill.skill_available and _skill.current_level < _skill.num_levels then
        --Cyclone.terminal.write("PRESSED: "..id)
        _skill:increaseLevel()
        self.points_available = self.points_available - 1
  
        self:refresh()
      end
    end
  end
end
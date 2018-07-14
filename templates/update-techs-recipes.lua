local check = function(force, techname)
  if force.technologies[techname] ~= nil and force.technologies[techname].researched then
    force.technologies[techname].researched = false
    force.technologies[techname].researched = true
  end
end

for i, force in pairs(game.forces) do
  force.reset_recipes()
  force.reset_technologies()
  check(force, "logicarts-tech1")
  check(force, "logicarts-tech2")
  check(force, "logicarts-tech-stops")
  check(force, "logicarts-tech-groups")
end
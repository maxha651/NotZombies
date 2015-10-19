return {
  version = "1.1",
  luaversion = "5.1",
  tiledversion = "2015-10-14",
  orientation = "orthogonal",
  renderorder = "right-down",
  width = 22,
  height = 22,
  tilewidth = 70,
  tileheight = 70,
  nextobjectid = 2,
  properties = {},
  tilesets = {
    {
      name = "buttons-sheet",
      firstgid = 1,
      tilewidth = 70,
      tileheight = 70,
      spacing = 0,
      margin = 10,
      image = "../gfx/gui/buttons-sheet.png",
      imagewidth = 370,
      imageheight = 370,
      tileoffset = {
        x = 0,
        y = 0
      },
      properties = {},
      terrains = {},
      tilecount = 25,
      tiles = {}
    },
    {
      name = "blocks",
      firstgid = 26,
      tilewidth = 70,
      tileheight = 70,
      spacing = 0,
      margin = 10,
      image = "../gfx/environment/blocks.png",
      imagewidth = 370,
      imageheight = 90,
      tileoffset = {
        x = 0,
        y = 0
      },
      properties = {},
      terrains = {},
      tilecount = 5,
      tiles = {
        {
          id = 0,
          properties = {
            ["collidable"] = "true"
          }
        },
        {
          id = 1,
          properties = {
            ["collidable"] = "true"
          }
        },
        {
          id = 2,
          properties = {
            ["collidable"] = "true"
          }
        },
        {
          id = 3,
          properties = {
            ["collidable"] = "true"
          }
        },
        {
          id = 4,
          properties = {
            ["collidable"] = "true"
          }
        }
      }
    },
    {
      name = "text",
      firstgid = 31,
      tilewidth = 70,
      tileheight = 70,
      spacing = 14,
      margin = 14,
      image = "../gfx/gui/text.png",
      imagewidth = 616,
      imageheight = 616,
      tileoffset = {
        x = 0,
        y = 0
      },
      properties = {},
      terrains = {},
      tilecount = 49,
      tiles = {}
    },
    {
      name = "text-medium",
      firstgid = 80,
      tilewidth = 140,
      tileheight = 140,
      spacing = 28,
      margin = 28,
      image = "../gfx/gui/text-medium.png",
      imagewidth = 1232,
      imageheight = 1232,
      tileoffset = {
        x = 0,
        y = 0
      },
      properties = {},
      terrains = {},
      tilecount = 49,
      tiles = {}
    }
  },
  layers = {
    {
      type = "tilelayer",
      name = "Tile Layer 1",
      x = 0,
      y = 0,
      width = 22,
      height = 22,
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 80, 0, 0, 81, 0, 0, 82, 0, 0, 83, 0, 0, 84, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 62, 66, 67, 68, 68, 0, 33, 40, 73, 0, 74, 60, 32, 32, 53, 40, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 5, 0, 11, 12, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 52, 53, 54, 55, 0, 0, 0, 9, 10, 0, 16, 17, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 59, 60, 61, 62, 0, 0, 0, 6, 7, 0, 1, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 66, 67, 68, 69, 70, 0, 0, 8, 0, 0, 2, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      }
    },
    {
      type = "imagelayer",
      name = "Image Layer 1",
      x = 70,
      y = 70,
      visible = true,
      opacity = 1,
      image = "",
      properties = {}
    }
  }
}

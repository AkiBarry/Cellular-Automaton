import java.util.*;

LifeType life_type;
GameState game_state;

void setup() {
  fullScreen();
  colorMode(HSB, 1.0);
  background(1.0, 0.0, 0.1);
  
  
  life_type = new LifeType("3", "23");
  game_state = new GameState(displayWidth, displayHeight, 12, life_type);
}

void draw() {
  if (mousePressed && mouseX >= 0 && mouseX < displayWidth && mouseY >= 0 && mouseY < displayHeight) {
    game_state.add_point(mouseX, mouseY);
  }
  
  if (game_state.update()) {
    background(1.0, 0.0, 0.1);
  }
  
  game_state.draw();
}

void keyPressed() {
  if (key == ' ')
    game_state.toggle_pause();
}

public class GameState {
  Grid grid_state;
  LifeType life_type;
  boolean paused;
  
  GameState(int width, int height, int scale, LifeType life_type) {
    this.grid_state = new Grid(width, height, scale);
    this.life_type = life_type;
    this.paused = true;
  }
  
  void toggle_pause() {
    paused = !paused;
  }
  
  boolean update() {
    if (paused)
      return false;
      
    grid_state.update(life_type.born, life_type.survive);
    
    return true;
  }
  
  void add_point(int x, int y) {
    grid_state.add_point(x, y);
  }
  
  void draw() {
    grid_state.draw();
  }
}

private class Grid {
  byte[][][] state;
  boolean current_frame;
  int width, height, scale;
  
  Grid(int width, int height, int scale) {
    state = new byte[width / scale][height / scale][2];
    current_frame = false;
    this.width = width / scale;
    this.height = height / scale;
    this.scale = scale;
  }
  
  void add_point(int x, int y) {
    state[x / scale][y / scale][current_frame ? 1 : 0] = 1;
  }
  
  void update(Set<Integer> born, Set<Integer> survive) {
    int old_frame_index = current_frame ? 1 : 0;
    current_frame = !current_frame;
    int new_frame_index = current_frame ? 1 : 0;
    
    for (int i = 0; i < width; ++i) {
      for (int j = 0; j < height; ++j) {
        int num_neighbours = num_neighbours(i, j, old_frame_index);
        
        if (state[i][j][old_frame_index] == 1) { // If Alive
          state[i][j][new_frame_index] = (byte)(survive.contains(num_neighbours) ? 1 : 0);
        } else {
          state[i][j][new_frame_index] = (byte)(born.contains(num_neighbours) ? 1 : 0);
        }
      }
    }
  }
  
  int num_neighbours(int x, int y, int frame_index) {
    int sum = 0;
    
    for (int dx = -1; dx <= 1; dx++) {
      for (int dy = -1; dy <= 1; dy++) {
        if (dx == 0 && dy == 0) {
          continue;
        }
        if (is_in_bounds(x + dx, y + dy)) {
          sum += state[x+dx][y+dy][frame_index];
        }
      }
    }
    
    return sum;
  }
  
  boolean is_in_bounds(int x, int y) {
    return x >= 0 && y >= 0 && x < this.width && y < this.height;
  }
  
  void draw() {
    int frame_index = current_frame ? 1 : 0;
    for (int i = 0; i < width; ++i) {
      for (int j = 0; j < height; ++j) {
        if (state[i][j][frame_index] == 1) {
          fill(0.0, 0.0, 1.0);
          rect(i * scale, j * scale, scale, scale);
        }
      }
    }
  }
}

public class LifeType {
  public Set<Integer> born;
  public Set<Integer> survive;
  
  LifeType(String born_values, String survive_values) {
    born = new HashSet<>();
    survive = new HashSet<>();
    
    for (char amount : born_values.toCharArray()) {
      born.add(amount - '0');
    }
    
    for (char amount : survive_values.toCharArray()) {
      survive.add(amount - '0');
    }
  }
}

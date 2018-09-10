import hype.*;
import hype.extended.behavior.HSwarm;
import hype.extended.behavior.HTimer;
import hype.extended.colorist.HColorPool;

HSwarm        swarm;
HDrawablePool pool;
HTimer        timer;

int time;

void setup() {
  //size(1920,1080);
  fullScreen();
  H.init(this).background(#242424).autoClear(false);

  time = 0;
    
  // start at center
  swarm = new HSwarm()
    .addGoal(width / 2.0, height / 2.0, 0.0)
    .speed(5)
    .turnEase(0.05f)
    .twitch(20)
  ;

  pool = new HDrawablePool(40);
  pool.autoAddToStage()
    .add(new HRect().rounding(4))
    .colorist(new HColorPool(#FFFFFF, #F7F7F7, #ECECEC, #333333, #0095a8, #00616f, #FF3300, #FF6600).fillOnly())
    .onCreate(
      new HCallback() {
        public void run(Object obj) {
          HDrawable d = (HDrawable) obj;
          d
            .strokeWeight(2)
            .stroke(#000000, 100)
            .size((int)random(10,20), (int)random(2,6) )
            .loc(width/2, height/2)
            .anchorAt(H.CENTER)
          ;

          swarm.addTarget(d);
        }
      }
    )
  ;

  timer = new HTimer()
    .numCycles( pool.numActive() )
    .interval(250)
    .callback(
      new HCallback() { 
        public void run(Object obj) {
          pool.request();
        }
      }
    )
  ;
}

void loadJSONData() {
  
  String[] json = loadStrings("http://192.168.1.69:5000/walabot/api/v1.0/sensortargets");
  for(String s: json){
    println(s);
  }

  saveStrings("data.json", json);

  JSONObject jobj =  loadJSONObject("data.json");
  
  JSONArray targetsJSONArray = jobj.getJSONArray("sensortargets");
  
  // replace old goals with new target positions
  swarm.goals().removeAll();

  for(int i = 0 ; i < targetsJSONArray.size() ; i++){
    
    float x;
    float y;
    float z;
    
    JSONObject eventObject = targetsJSONArray.getJSONObject(i);
     
    x = eventObject.getFloat("xPosCm");
    y = eventObject.getFloat("yPosCm");
    z = eventObject.getFloat("zPosCm");
    
    // translate from Walabot Cartesian coordinates to pixels, and adjust for screen size
    x = (width / 2) + ((x / 100.0) * width);
    y = (height / 2) + ((y / 100.0) * height);
    z = z * 10;
    
    
    // debug
    println("x" + i + ": " + x );
    println("y" + i + ": " + y );
    println("z" + i + ": " + z );
    //ellipse(x, y, z, z);
    
    
    swarm.addGoal(x, y, z);
  }
}

void draw() {
  
  if (millis() > time) {
  
    time = time + 3000;
    thread("loadJSONData");
    
  }
  
  H.drawStage();

}

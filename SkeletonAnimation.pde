
int count = 0;

int circleSmoothness = 12;

int c = 0;

//カメラの値
float cameraR = 400;
float vert = 98;
float hori = 15;

boolean motion = false;
boolean run = false;

//ここコピペ　+α
//https://qiita.com/dqn/items/fd67704045fe9a02dd1f
//processingではキーを一つしか判別できないので
//押された時にboolをtrue離すとfalseで同時押しを認識する
boolean left,right,up,down,z,v,d,x,b;

int frame = 0;
int inter = 0;

//モデル
Bone MainBone;

//キーフレーム
Joints Stop;
Joints Run[];
Joints Walk[];
Joints TargetMotion[];

//キーフレーム間の間隔
static int interval[] = {6, 5, 6, 5}; //走るよう
static int walkInterval[] = {9,6,9,6};
//現在どっちのインターバルを使用しているか
int TMInterval[] = {0,0,0,0};

static float runSpeed = 25;
static float walkSpeed = 5;

Vector3 position;

//モデルの状態
Joints main;
//１フレームあたりの変化量
Joints Lerp;

//マップ自動生成のための現在地
//人のxz座標における位置　pos　に対して
//4000x - 2000 < pos < 4000x + 2000 を満たす整数　(x,z)
int floorX = 0;
int floorZ = 0;

PImage TreeImg;
PImage floorImg;

void setup()
{
  size(1200, 700, P3D);
  //60でも動いたけど念のため
  //ここを変えるとインターバルも変える必要あり
  frameRate(30);
  TreeImg = loadImage("TreeImg.png");
  floorImg = loadImage("floorImg.png");
  textureMode(NORMAL);
  
  MainBone = new Bone(new Vector3(150, 100, 0));

  main = new Joints();
  Lerp = new Joints();
  Stop = new Joints();
  Run = new Joints[4];
  Walk = new Joints[4];
  TargetMotion = new Joints[4];
  for (int i=0; i<4; i++)
  {
    Run[i] = new Joints();
    Walk[i] = new Joints();
    TargetMotion[i] = new Joints();
  }
  
  
  
  Vector3 R_1[] = {
    new Vector3(0, 0, 0), //b
    new Vector3(0, 0, 0), //w
    new Vector3(0, 30, 0), //wl
    new Vector3(80, -25, 0), //ull
    new Vector3(-140, 0, 0), //lll
    new Vector3(-40, 0, 0), //fl
    new Vector3(0, 30, 0), //wr
    new Vector3(-35, -25, 5), //ulr
    new Vector3(-70, 0, -5), //llr
    new Vector3(0, 0, 0), //fr
    new Vector3(-15, 0, 0), //s
    new Vector3(0, -20, 0), //shl
    new Vector3(-70, 0, 0), //ual
    new Vector3(90, 20, 0), //lal
    new Vector3(0, -20, 0), //shr
    new Vector3(60, 0, 0), //uar
    new Vector3(100, -20, 0), //lar
    new Vector3(0, 0, 0), 
  };
  Run[0].setVal(R_1);
  Vector3 R_2[] = {
    new Vector3(0, 0, 0), //体
    new Vector3(0, 0, 0), //weist
    new Vector3(0, 10, 0), //w_l
    new Vector3(25, -13, 0), //ul_l
    new Vector3(-15, 0, 0), //ll_l
    new Vector3(0, 0, 0), //f_l
    new Vector3(0, 10, 0), //w_r
    new Vector3(-65, 0, 3), //ul_r
    new Vector3(-20, 0, -3), //ll_r 
    new Vector3(-30, 0, 0), //f_r
    new Vector3(-15, 0, 0), // s
    new Vector3(0, -20, 0), //sh_l
    new Vector3(-40, 0, 0), //ua_l
    new Vector3(80, 0, 0), //la_l
    new Vector3(0, -20, 0), //sh_r
    new Vector3(20, 0, 0), //ua_r
    new Vector3(80, 0, 0), //la_r
    new Vector3(0, 0, 0), 
  };
  Run[1].setVal(R_2);
  Vector3 R_3[] = {
    new Vector3(0, 0, 0), //b
    new Vector3(0, 0, 0), //w
    new Vector3(0, -30, 0), //wl
    new Vector3(-35, 25, -5), //ull
    new Vector3(-70, 0, 5), //lll
    new Vector3(-40, 0, 0), //fl
    new Vector3(0, -30, 0), //wr
    new Vector3(80, 25, 0), //ulr
    new Vector3(-140, 0, 0), //llr
    new Vector3(0, 0, 0), //fr
    new Vector3(-15, 0, 0), //s
    new Vector3(0, 20, 0), //shl
    new Vector3(60, 0, 0), //ual
    new Vector3(100, 20, 0), //lal
    new Vector3(0, 20, 0), //shr
    new Vector3(-70, 0, 0), //uar
    new Vector3(90, -20, 0), //lar
    new Vector3(0, 0, 0), 
  };
  Run[2].setVal(R_3);
  Vector3 R_4[] = {
    new Vector3(0, 0, 0), //b
    new Vector3(0, 0, 0), //w
    new Vector3(0, -10, 0), //wl
    new Vector3(-65, 0, -3), //ull
    new Vector3(-20, 0, 3), //lll
    new Vector3(-30, 0, 0), //fl
    new Vector3(0, -10, 0), //wr
    new Vector3(25, 13, 0), //ulr
    new Vector3(-15, 0, 0), //llr
    new Vector3(0, 0, 0), //fr
    new Vector3(-15, 0, 0), //s
    new Vector3(0, 20, 0), //shl
    new Vector3(20, 0, 0), //ual
    new Vector3(80, 0, 0), //lal
    new Vector3(0, 20, 0), //shr
    new Vector3(-40, 0, 0), //uar
    new Vector3(80, 0, 0), //lar
    new Vector3(0, 0, 0), 
  };
  Run[3].setVal(R_4);
  Vector3 W_1[] = {
    new Vector3(0, 0, 0), //b
    new Vector3(0, 0, 0), //w
    new Vector3(0, 20, 5), //wl
    new Vector3(30, -20, -5), //ull
    new Vector3(-80, 0, 0), //lll
    new Vector3(-30, 0, 0), //fl
    new Vector3(0, 20, 5), //wr
    new Vector3(-5, -20, -5), //ulr
    new Vector3(0, 0, 0), //llr
    new Vector3(0, 0, 0), //fr
    new Vector3(0, 0, 0), //s
    new Vector3(0, -10, 0), //shl
    new Vector3(-20, 8, 0), //ual
    new Vector3(5, 0, 0), //lal
    new Vector3(0, -10, 0), //shr
    new Vector3(20, 0, 0), //uar
    new Vector3(10, -5, 0), //lar
    new Vector3(0, 0, 0), 
  };
  Walk[0].setVal(W_1);
  Vector3 W_2[] = {
    new Vector3(0, 0, 0), //b
    new Vector3(0, 0, 0), //w
    new Vector3(0, 0, 0), //wl
    new Vector3(30, 0, 0), //ull
    new Vector3(-20, 0, 0), //lll
    new Vector3(5, 0, 0), //fl
    new Vector3(0, 0, 0), //wr
    new Vector3(-25, 0, 0), //ulr
    new Vector3(-10, 0, 0), //llr
    new Vector3(-10, 0, 0), //fr
    new Vector3(0, 0, 0), //s
    new Vector3(0, -5, 0), //shl
    new Vector3(-10, 3, 0), //ual
    new Vector3(10, 10, 0), //lal
    new Vector3(0, -5, 0), //shr
    new Vector3(10, 0, 0), //uar
    new Vector3(10, -10, 0), //lar
    new Vector3(0, 0, 0), 
  };
  Walk[1].setVal(W_2);
  Vector3 W_3[] = {
    new Vector3(0, 0, 0), //b
    new Vector3(0, 0, 0), //w
    new Vector3(0, -20, -5), //wl
    new Vector3(-5, 20, 5), //ull
    new Vector3(0, 0, 0), //lll
    new Vector3(0, 0, 0), //fl
    new Vector3(0, -20, -5), //wr
    new Vector3(30, 20, 5), //ulr
    new Vector3(-80, 0, 0), //llr
    new Vector3(-30, 0, 0), //fr
    new Vector3(0, 0, 0), //s
    new Vector3(0, 10, 0), //shl
    new Vector3(20, 0, 0), //ual
    new Vector3(10, 5, 0), //lal
    new Vector3(0, 10, 0), //shr
    new Vector3(-20, -8, 0), //uar
    new Vector3(5, 0, 0), //lar
    new Vector3(0, 0, 0), 
  };
  Walk[2].setVal(W_3);
  Vector3 W_4[] = {
    new Vector3(0, 0, 0), //b
    new Vector3(0, 0, 0), //w
    new Vector3(0, 0, 0), //wl
    new Vector3(-25, 0, 0), //ull
    new Vector3(-10, 0, 0), //lll
    new Vector3(-10, 0, 0), //fl
    new Vector3(0, 0, 0), //wr
    new Vector3(30, 0, 0), //ulr
    new Vector3(-20, 0, 0), //llr
    new Vector3(5, 0, 0), //fr
    new Vector3(0, 0, 0), //s
    new Vector3(0, 5, 0), //shl
    new Vector3(10, 0, 0), //ual
    new Vector3(10, 10, 0), //lal
    new Vector3(0, 5, 0), //shr
    new Vector3(-10, -3, 0), //uar
    new Vector3(10, -10, 0), //lar
    new Vector3(0, 0, 0), 
  };
  Walk[3].setVal(W_4);
  
  inter = 0;
  background(150);
  position = new Vector3(0, 0, 0);
  MainBone.positions[0] = position;
}

void draw()
{
  background(160,210,235);
  translate(width / 2, height / 2, 0);
  
  Vector3 p = MainBone.positions[0];
  
  float cameraX = cameraR * cos(radians(vert)) * cos(radians(hori)) + p.x;
  float cameraZ = cameraR * sin(radians(vert)) * cos(radians(hori)) + p.z;
  
  
  camera(cameraX,-cameraR * sin(radians(hori)) - 75+ p.y,cameraZ,p.x,-75+p.y,p.z,0,1,0);
  
  //動かすところ
  if (keyPressed)
  {
    if (arrayKey())
    {
      if (frame >= inter && frame != 0)//キーフレームの変わり目
      {
        if(c == 0 || c == 2) //足が地についた時、走るのか歩くのか確認する
        {
          if(b && (!run || !motion))
          {
            TargetMotion = Run; 
            TMInterval = interval;
            run = true;
          }
          else if(!b && (run || !motion))
          {
            TargetMotion = Walk; 
            TMInterval = walkInterval;
            run = false;
          }
        }
        Lerp.lerp(main, TargetMotion[c], TMInterval[c]);
        inter =  TMInterval[c];
        frame = 0;
        c = c == 3 ? 0 : c + 1;
      }
      motion = true;
    }
    if(z)
      vert -= 2.5;
    if(v)
      vert += 2.5;
    if(d)
      hori -=2.5;
    if(x)
      hori +=2.5;
  }
  vert = vert >= 360 ? vert-360 : vert <= 0 ? vert + 360 : vert;
  if(motion && !arrayKey() ) //止まる
  {
    Lerp.lerp(main, Stop, 10);
    motion = false;
    inter = 10;
    frame = 0;
    c = 0;
  }
  else if(frame == 10)
  {
    Lerp.lerp(main, main, 10);
  }
  main.add(Lerp);

  noStroke();

  
  //進む方向
  Vector3 direction = new Vector3(0,0,-1);
  
  if(motion)
  {
    int arrayKeyCount = 0;
    float d = 0;
    if(up)
    {
      arrayKeyCount += 1;
    }
    if(left)
    {
      d -= 90;
      arrayKeyCount += 1;
    }
    if(down)
    {
      d -= 180;
      arrayKeyCount += 1;
    }
    if(right)
    {
      d -= 270;
      arrayKeyCount += 1;
    }
    //向きたい角度
    float dir = vert - 90 + ((right && up) ? 45 : d/arrayKeyCount);
    
    //ガタガタしないように誤差を許容
    if(abs(dir - main.joint[Body].value.y) > 5)
    {
      float diff = dir - main.joint[Body].value.y;
      if (abs(diff) > 360)
      {
        main.joint[Body].value.y += diff > 0 ? 360 : -360;
      }
      //0 <= diff <= 360
      diff %= 360;
      diff += 360;
      diff %= 360;
      // 右回りと左回りどちらが近いか
      if (abs(diff) < 10)
        main.joint[Body].value.y += diff > 180 ? -2.5 : 2.5;
      else
        main.joint[Body].value.y += diff > 180 ? -6 : 6;
    }
    direction.rotationY(main.joint[Body].value.y);
    if(run)
      position.add(mul(direction,runSpeed));
    else
      position.add(mul(direction,walkSpeed));
  }
  MainBone.positions[0] = position;
  
  frame++;
  
  //描画
  //地面
  beginShape(TRIANGLE);
  texture(floorImg);
  
  floorX += floorX * 4000 + 2000 < position.x ? 1 : floorX * 4000 - 2000 > position.x ? -1 : 0;
  floorZ += floorZ * 4000 + 2000 < position.z ? 1 : floorZ * 4000 - 2000 > position.z ? -1 : 0;
  
  
  fill(150,200,150);
  for(int i=-1;i<2;i++)
  {
    float fx = 4000 * (floorX + i);
    for(int j = -1;j<2;j++)
    {
      float fz = 4000 * (floorZ + j);
      Vector3 f1 = new Vector3(2000 + fx,30,2000 + fz);
      Vector3 f2 = new Vector3(2000 + fx,30,-2000 + fz);
      Vector3 f3 = new Vector3(-2000 + fx,30,2000 + fz);
      Vector3 f4 = new Vector3(-2000 + fx,30,-2000 + fz);
      
      quadImg(f1,f2,f3,f4);
    }
  }
  
  endShape();
  
  lights();
  //人
  beginShape(TRIANGLE);
  fill(255,255,255);
  MainBone.Debug(main);
  triangle(MainBone.positions[Spine],MainBone.positions[Weist_L],MainBone.positions[Weist_R]);
  triangle(MainBone.positions[Shoulder_L],MainBone.positions[Shoulder_R],MainBone.positions[Weist]);
  
  endShape();
  
  //木
  beginShape(TRIANGLES);
  texture(TreeImg);
  for(int i=-2;i<1;i++)
  {
    
    float fx = 4000 * (floorX + (i==-2 ? 1 :i));
    for(int j = -2;j<1;j++)
    {
      float fz = 4000 * (floorZ + (j==-2 ? 1 :j));
      drawTree(1000+fx,100+fz,200,cameraX,cameraZ);
      drawTree(-200+fx,-900+fz,300,cameraX,cameraZ);
      drawTree(-700+fx,100+fz,230,cameraX,cameraZ);
      drawTree(600+fx,750+fz,250,cameraX,cameraZ);
      drawTree(-400+fx,1350+fz,350,cameraX,cameraZ);
      drawTree(800+fx,-600+fz,240,cameraX,cameraZ);
      drawTree(-1200+fx,0+fz,260,cameraX,cameraZ);
      drawTree(-1700+fx,1300+fz,280,cameraX,cameraZ);
      drawTree(1600+fx,1750+fz,250,cameraX,cameraZ);
      drawTree(-400+fx,-1350+fz,250,cameraX,cameraZ);
      drawTree(1000+fx,-1500+fz,270,cameraX,cameraZ);
      drawTree(1200+fx,-900+fz,320,cameraX,cameraZ);
    }
  }
     
  endShape();
  
}

void Vec3Line(Vector3 a, Vector3 b)
{
  line(a.x, a.y, a.z, b.x, b.y, b.z);
}

void triangle(Vector3 a, Vector3 b, Vector3 c)
{
  a.vert();
  b.vert();
  c.vert();
}

void triangleImg(Vector3 a, Vector3 b, Vector3 c,int p) //pはuv座標が上かしたか
{
  if(p == 0)
  {
    a.vert(0,0);
    b.vert(1,0);
    c.vert(0,1);
  }
  if(p == 1)
  {
     a.vert(1,0);
    b.vert(0,1);
    c.vert(1,1);
  }
}
void quad(Vector3 a, Vector3 b, Vector3 c, Vector3 d)
{
  triangle(a, b, c);  
  triangle(b, c, d);
}

void quadImg(Vector3 a, Vector3 b, Vector3 c, Vector3 d)
{
  triangleImg(a, b, c,0);  
  triangleImg(b, c, d,1);
}

//部位のインデックスを返す
// for文で回したときの親のインデックスがなるべく順番になるように並べる
// モデリングソフト等でリギングして、きれいに並べてない場合,
// 深さ優先度探索して探索した順番に並び替えれば最適化できるのでは
static int Body = 0;
static int Weist = 1;
static int Weist_L = 2;
static int UpperLeg_L = 3;
static int LowerLeg_L = 4;
static int Foot_L = 5;
static int Weist_R = 6;
static int UpperLeg_R = 7;
static int LowerLeg_R = 8;
static int Foot_R = 9;
static int Spine = 10;
static int Shoulder_L = 11;
static int UpperArm_L = 12;
static int LowerArm_L = 13;
static int Shoulder_R = 14;
static int UpperArm_R = 15;
static int LowerArm_R = 16;
static int Hed = 17;

Vector3 right() {
  return new Vector3(1, 0, 0);
}

//回転させるときsin(90°)で辺な値になるので　90°で割れる時はこれで回す
//90°単位で何回ぶんか
// 0 <= result <= 3 で返す
static int mod360per90(float x)
{
  int n = int(x % 360.0);
  n = n >= 0 ? n : n+360;
  n /= 90;
  return n;
}

class Vector3
{
  float x, y, z;
  Vector3(float x, float y, float z) 
  {
    this.x = x;
    this.y = y;
    this.z = z;
  }
  //x軸周りに回転
  void rotationX(float x)
  {
    if ( x % 360 == 0) {
    } else if (x % 90 == 0)
    {
      for (int i=0; i < mod360per90(x); i++)
      {
        float z_ = z;
        this.z = -this.y;
        this.y = z_;
      }
    } else
    {
      float z_ = z;
      this.z = this.z * cos(radians(x)) - this.y * sin(radians(x));
      this.y = this.y * cos(radians(x)) + z_ * sin(radians(x));
    }
  }
  //y軸周りに回転
  void rotationY(float y)
  {
    if ( y % 360 == 0) {
    } else if (y % 90 == 0)
    {
      for (int i=0; i < mod360per90(y); i++)
      {
        float x_ = x;
        this.x = -this.z;
        this.z = x_;
      }
    } else
    {
      float x_ = this.x;
      this.x = this.x * cos(radians(y)) - this.z * sin(radians(y));
      this.z = this.z * cos(radians(y)) + x_ * sin(radians(y));
    }
  }
  //z軸周りに回転
  void rotationZ(float z)
  {
    if ( z % 360 == 0) {
    } else if (z % 90 == 0)
    {
      for (int i=0; i < mod360per90(z); i++)
      {
        float x_ = x;
        this.x = -this.y;
        this.y = x_;
      }
    } else
    {
      float x_ = this.x;
      this.x = this.x * cos(radians(z)) - this.y * sin(radians(z));
      this.y = this.y * cos(radians(z)) + x_ * sin(radians(z));
    }
  }

  void mul(float a)
  {
    this.x *= a;
    this.y *= a;
    this.z *= a;
  }

  void add(Vector3 a)
  {
    this.x += a.x; 
    this.y += a.y; 
    this.z += a.z;
  }

  void vert()
  {
    vertex(this.x, this.y, this.z);
  }
  void vert(float x,float y)
  {
    vertex(this.x, this.y, this.z,x,y);
  }

  void Debug()
  {
    print(this.x);
    print(" ");
    print(this.y);
    print(" ");
    println(z);
  }

  void Debug(String v)
  {
    print(v);
    print(": ");
    print(this.x);
    print(" ");
    print(this.y);
    print(" ");
    println(z);
  }
  void Debug(int v)
  {
    print(v);
    print(": ");
    print(this.x);
    print(" ");
    print(this.y);
    print(" ");
    println(z);
  }
  
  Vector3 Copy()
  {
    return new Vector3(this.x,this.y,this.z);
  }

  float abs()
  {
    return this.x * this.x + this.y * this.y + this.z * this.z;
  }
}

Vector3 Vadd(Vector3 a, Vector3 b)
{
  float x = a.x+b.x;
  float y = a.y+b.y;
  float z = a.z+b.z;
  Vector3 result = new Vector3(x, y, z);
  return result;
}
Vector3 mul(Vector3 a, float b)
{
  Vector3 r = new Vector3(a.x, a.y, a.z);
  r.mul(b);
  return r;
}

//関節の向きに合わせるもの
static Vector3 Vrotate(Vector3 p, Vector3 d)
{
  //この順番でないとおかしくなる
  Vector3 result = p;
  p.rotationZ(d.z);
  p.rotationX(d.x);
  p.rotationY(d.y);
  return result;
}

Vector3 Vlerp(Vector3 a, Vector3 target, int step)
{
  Vector3 result = new Vector3(target.x, target.y, target.z);
  result.add(mul(a, -1));
  result.mul((float)1/(float)step);
  return result;
}



class Dir //角度
{
  int num;
  Vector3 value, sum;
  Dir Parent;
  void set(float x, float y, float z)
  {
    this.value = new Vector3(x, y, z);
    this.sum = new Vector3(0, 0, 0);
    num = count;
    count++;
  }
  Dir()
  {
    this.set(0, 0, 0);
    this.Parent = null;
  }
  Dir(float x, float y, float z)
  {
    this.set(x, y, z);
    this.Parent = null;
  }
  Dir(float x, float y, float z, Dir Parent)
  {
    this.set(x, y, z);
    this.Parent = null;
    this.Parent = Parent;
  }


  void add(Dir val)
  {
    this.value.add(val.value);
  }

  //動画部分　線形補間
  void lerp(Dir a, Dir target, int step)
  {
    this.value.x = (target.value.x - a.value.x) / step;
    this.value.y = (target.value.y - a.value.y) / step;
    this.value.z = (target.value.z - a.value.z) / step;
  }

  void Culc()
  { 
    if (this.Parent != null)
      this.sum = Vadd(this.value, this.Parent.sum);
    else
      this.sum = this.value;
  }
}





class Joints
{
  Dir joint[];

  Joints()
  {
    joint = new Dir[18];
    joint[Body] = new Dir(0, 0, 0);
    joint[Weist] = new Dir(0, 0, 0, joint[Body]);
    joint[Weist_L] = new Dir(0, 0, 0, joint[Weist]);
    joint[Weist_R] = new Dir(0, 0, 0, joint[Weist]);
    joint[UpperLeg_L] = new Dir(0, 0, 0, joint[Weist_L]);
    joint[UpperLeg_R] = new Dir(0, 0, 0, joint[Weist_R]);
    joint[LowerLeg_L] = new Dir(0, 0, 0, joint[UpperLeg_L]);
    joint[LowerLeg_R] = new Dir(0, 0, 0, joint[UpperLeg_R]);
    joint[Foot_L] = new Dir(0, 0, 0, joint[LowerLeg_L]);
    joint[Foot_R] = new Dir(0, 0, 0, joint[LowerLeg_R]);
    joint[Spine] = new Dir(0, 0, 0, joint[Weist]);
    joint[Shoulder_L] = new Dir(0, 0, 0, joint[Spine]);
    joint[Shoulder_R] = new Dir(0, 0, 0, joint[Spine]);
    joint[UpperArm_L] = new Dir(0, 0, 0, joint[Shoulder_L]);
    joint[UpperArm_R] = new Dir(0, 0, 0, joint[Shoulder_R]);
    joint[LowerArm_L] = new Dir(0, 0, 0, joint[UpperArm_L]);
    joint[LowerArm_R] = new Dir(0, 0, 0, joint[UpperArm_R]);
    joint[Hed] = new Dir(0, 0, 0, joint[Spine]);
  }

  void setVal(Vector3 val[])
  {
    for (int i=0; i<18; i++)
    {
      joint[i].value = val[i];
    }
  }

  void setVal(Vector3 val[], float v)
  {
    for (int i=0; i<18; i++)
    {
      joint[i].value = mul(val[i], v);
    }
  }

  void add(Joints v)
  {
    for (int i=0; i<joint.length; i++)
    {
      this.joint[i].add(v.joint[i]);
    }
  }

  void lerp(Joints a, Joints target, int step)
  {
    for (int i=1; i<joint.length; i++)
    {
      this.joint[i].lerp(a.joint[i], target.joint[i], step);
    }
  }

  void Culc()
  {
    for (int i=0; i<18; i++)
      joint[i].Culc();
  }
}



class Bone
{
  Vector3 positions[];
  Vector3 Normal[][];
  Vector3 local[];
  Vector3 Model[][];
  int parent[];
  Bone(Vector3 pos)
  {
    positions = new Vector3[18];
    Normal = new Vector3[18][3];
    local = new Vector3[18];
    for (int i=0; i<18; i++)
    {
      positions[i] = new Vector3(0, 0, 0);
      Normal[i][0] = new Vector3(1,0,0);
      Normal[i][0] = new Vector3(0,1,0);
      Normal[i][0] = new Vector3(0,0,1);
    }
    positions[0] = pos;
    parent = new int[18];
    parent[Body] = -1;
    parent[Weist] = Body;
    parent[Weist_L] = Weist;
    parent[Weist_R] = Weist;
    parent[UpperLeg_L] = Weist_L;
    parent[UpperLeg_R] = Weist_R;
    parent[LowerLeg_L] = UpperLeg_L;
    parent[LowerLeg_R] = UpperLeg_R;
    parent[Foot_L] = LowerLeg_L;
    parent[Foot_R] = LowerLeg_R;
    parent[Spine] = Weist;
    parent[Shoulder_L] = Spine;
    parent[Shoulder_R] = Spine;
    parent[UpperArm_L] = Shoulder_L;
    parent[UpperArm_R] = Shoulder_R;
    parent[LowerArm_L] = UpperArm_L;
    parent[LowerArm_R] = UpperArm_R;
    parent[Hed] = Spine;
    
    local[Body] = new Vector3(0,0,0);
    local[Weist] = new Vector3(0,-75,0);
    local[Weist_L] = new Vector3(-15,0,0); 
    local[Weist_R] = new Vector3(15,0,0);
    local[UpperLeg_L] = new Vector3(0,40,0);
    local[UpperLeg_R] = new Vector3(0,40,0);
    local[LowerLeg_L] = new Vector3(0,35,0);
    local[LowerLeg_R] = new Vector3(0,35,0);
    local[Foot_L] = new Vector3(0,0,-20);
    local[Foot_R] = new Vector3(0,0,-20);
    local[Spine] = new Vector3(0,-55,0);
    local[Shoulder_L] = new Vector3(-25,0,0);
    local[Shoulder_R] = new Vector3(25,0,0);
    local[UpperArm_L] = new Vector3(0,35,0);
    local[UpperArm_R] = new Vector3(0,35,0);
    local[LowerArm_L] = new Vector3(0,35,0);
    local[LowerArm_R] = new Vector3(0,35,0);
    local[Hed] = new Vector3(0,-20,0);
    
    Model = new Vector3[12][24];
      Model[0] = Cylinder(2,5,local[UpperArm_L].y,12); 
      Model[1] = Cylinder(2,5,local[LowerArm_L].y,12); 
      Model[2] = Cylinder(2,5,local[UpperArm_R].y,12); 
      Model[3] = Cylinder(2,5,local[LowerArm_R].y,12); 
      Model[4] = Cylinder(2,5,local[Hed].y,12); 
      Model[5] = Cylinder(2,5,local[Spine].y,12); 
      Model[6] = Cylinder(2,6,local[UpperLeg_L].y,12); 
      Model[7] = Cylinder(2,6,local[LowerLeg_L].y,12); 
      Model[8] = Cylinder(2,6,local[UpperLeg_R].y,12); 
      Model[9] = Cylinder(2,6,local[LowerLeg_R].y,12); 
      Model[10] = Cylinder_z(2,5,local[Foot_L].z,12); 
      Model[11] = Cylinder_z(2,5,local[Foot_R].z,12); 
  }

  void culc(Joints v)
  {
    v.Culc();
    for (int i=0; i<18; i++)
    {
      Vector3 dir = v.joint[i].sum;
      Normal[i][0] = Vrotate(new Vector3(1, 0, 0), dir);
      Normal[i][1] = Vrotate(new Vector3(0, 1, 0), dir);
      Normal[i][2] = Vrotate(new Vector3(0, 0, 1), dir);
      positions[i] = parent[i] >= 0 ? positions[parent[i]] : positions[i];
      positions[i] = Vadd(positions[i], mul(Normal[i][0],local[i].x));
      positions[i] = Vadd(positions[i], mul(Normal[i][1],local[i].y));
      positions[i] = Vadd(positions[i], mul(Normal[i][2],local[i].z));
    }
  }

  //親と線で結ぶ
  void Debug(Joints v)
  {
    culc(v);
    drawParts(Model[0],12);
    drawParts(Model[1],13);
    drawParts(Model[2],15);
    drawParts(Model[3],16);
    drawParts(Model[4],17);
    drawParts(Model[5],10);
    drawParts(Model[6],3);
    drawParts(Model[7],4);
    drawParts(Model[8],7);
    drawParts(Model[9],8);
    drawParts(Model[10],5);
    drawParts(Model[11],9);
  }
  
  //既に計算されてる時に
  Vector3[] Translate(Vector3 vertics[],int parts)
  {
    Vector3 result[] = new Vector3[vertics.length];
    for(int i=0;i<vertics.length;i++)
    {
      result[i] = positions[parent[parts]].Copy();
      result[i].add(mul(Normal[parts][0],vertics[i].x));
      result[i].add(mul(Normal[parts][1],vertics[i].y));
      result[i].add(mul(Normal[parts][2],vertics[i].z));
    }
    return result;
  }
  
  void drawParts(Vector3 v[],int parts)
  {
    Vector3 vertics[] = Translate(v,parts);
    drawCylinder(vertics,2,12);
  }
}


Vector3[] Cylinder(int h,float r,float l,int smoothness)
{
  Vector3 result[] = new Vector3[h * smoothness];
  float dl = l / (h - 1);
  float theta = PI / (smoothness-1) * 2;
  for(int i=0;i<h;i++)
  {
    float y = dl * i;
    for(int j=0;j<smoothness;j++)
    {
      float x = r * cos(theta * j);
      float z = r * sin(theta * j);
      result[i * smoothness + j] = new Vector3(x,y,z);
    }
  }
  
  return result;
}

Vector3[] Cylinder_z(int h,float r,float l,int smoothness)
{
  Vector3 result[] = new Vector3[h * smoothness];
  float dl = l / (h - 1);
  float theta = PI / (smoothness-1) * 2;
  for(int i=0;i<h;i++)
  {
    float z = dl * i;
    for(int j=0;j<smoothness;j++)
    {
      float x = r * cos(theta * j);
      float y = r * sin(theta * j);
      result[i * smoothness + j] = new Vector3(x,y,z);
    }
  }
  
  return result;
}

void drawCylinder(Vector3 vertics[],int h, int smoothness)
{
  for(int i=0;i<h-1;i++)
  {
    for(int j=0;j<smoothness-1;j++)
    {
      quad(vertics[i*smoothness + j],vertics[i*smoothness + j + 1],vertics[(i+1)*smoothness + j],vertics[(i + 1)*smoothness + j + 1]);
    }
    quad(vertics[i*smoothness],vertics[(i+1)*smoothness - 1],vertics[(i+1)*smoothness],vertics[(i + 2)*smoothness - 1]);
  }
}


//前の課題で書いたところ
void drawTree(float x,float z,float size,float cameraX,float cameraZ)
{
  float disX = cameraX - x, disZ =  cameraZ - z;

  float t = sqrt(disX * disX + disZ * disZ);
  disX /= t;
  disZ /= t;
  
  float tanX = disZ, tanZ = -disX;
    
    //葉っぱの大きいやつ
    //少し奥に書いて枝を見せる
    vertex(x + size * tanX - disX,-size * 0.66,z + size * tanZ - disZ,0,0.5);
    vertex(x - size * tanX - disX,-size * 0.66,z - size * tanZ - disZ,0.5,0.5);
    vertex(x + size * tanX - disX,-size*2.5,z + size * tanZ - disZ,0,0);
    vertex(x - size * tanX - disX,-size* 0.66,z - size * tanZ - disZ,0.5,0.5);
    vertex(x + size * tanX - disX,-size*2.5,z + size * tanZ - disZ,0,0);
    vertex(x - size * tanX - disX,-size*2.5,z - size * tanZ - disZ,0.5,0);
    
    //幹
    vertex(x + size * tanX,0,z + size * tanZ,0,1);
    vertex(x - size * tanX,0,z - size * tanZ,0.5,1);
    vertex(x + size * tanX,-size*2,z + size * tanZ,0,0.5);
    vertex(x - size * tanX,0,z - size * tanZ,0.5,1);
    vertex(x + size * tanX,-size*2,z + size * tanZ,0,0.5);
    vertex(x - size * tanX,-size*2,z - size * tanZ,0.5,0.5);
    
    //中くらいの葉
    vertex(x + size * tanX * .8 + disX * size /3,-size  ,z + size * tanZ * .8  + disZ * size /3,0.5,0.5);
    vertex(x - size * tanX * .8 + disX * size /3,-size  ,z - size * tanZ * .8  + disZ * size /3,0.75,0.5);
    vertex(x + size * tanX * .8 + disX * size /3,-size*2.3,z + size * tanZ * .8  + disZ * size /3,0.5,0.25);
    vertex(x - size * tanX * .8 + disX * size /3,-size  ,z - size * tanZ * .8  + disZ * size /3,0.75,0.5);
    vertex(x + size * tanX * .8 + disX * size /3,-size*2.3,z + size * tanZ * .8  + disZ * size /3,0.5,0.25);
    vertex(x - size * tanX * .8 + disX * size /3,-size*2.3,z - size * tanZ * .8  + disZ * size /3,0.75,0.25);
    
    //ハイライト
    vertex(x + size * tanX * 0.8 + disX * size /2,-size * 1.5,z + size * tanZ * 0.8 + disZ * size /2,0.5,0.25);
    vertex(x + disX * size /2,-size * 1.5,z  + disZ * size /2,0.75,0.25);
    vertex(x + size * tanX * 0.8 + disX * size /2,-size * 2.3,z + size * tanZ * 0.8 + disZ * size /2,0.5,0);
    vertex(x + disX * size /2,-size * 1.5,z + disZ * size /2,0.75,0.25);
    vertex(x + size * tanX * 0.8 + disX * size /2,-size * 2.3,z + size * tanZ * 0.8 + disZ * size /2,0.5,0);
    vertex(x + disX * size /2,-size * 2.3,z + disZ * size /2,0.75,0);
    
    //暗いところ
    vertex(x - size * tanX * 0.8 + disX * size /2,-size,z - size * tanZ * 0.8 + disZ * size /2,0.75,0.25);
    vertex(x + disX * size /2,-size,z  + disZ * size /2,1,0.25);
    vertex(x - size * tanX * 0.8 + disX * size /2,-size * 1.6,z - size * tanZ * 0.8 + disZ * size /2,0.75,0);
    vertex(x + disX * size /2,-size,z + disZ * size /2,1,0.25);
    vertex(x - size * tanX * 0.8 + disX * size /2,-size * 1.6,z - size * tanZ * 0.8 + disZ * size /2,0.75,0);
    vertex(x + disX * size /2,-size * 1.6,z + disZ * size /2,1,0);
}

boolean arrayKey(){ return left || right || up || down;}


//以下コピペ
void keyPressed() {
  if (keyCode == LEFT)  left  = true;
  if (keyCode == RIGHT) right = true;
  if (keyCode == UP)    up    = true;
  if (keyCode == DOWN)  down  = true;
  if (key == 'z') z = true;
  if (key == 'v') v = true;
  if (key == 'd') d = true;
  if (key == 'x') x = true;
  if (key == 'b') b = true;
}

void keyReleased() {
  if (keyCode == LEFT)  left  = false;
  if (keyCode == RIGHT) right = false;
  if (keyCode == UP)    up    = false;
  if (keyCode == DOWN)  down  = false;
  if (key == 'z') z = false;
  if (key == 'v') v = false;
  if (key == 'd') d = false;
  if (key == 'x') x = false;
  if (key == 'b') b = false;
}

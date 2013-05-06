part of RollerCoaster;

class TrackPart {
  String name;
  String trackType;
  List<CoasterSplineItem> points;

  TrackPart(this.name, this.trackType, this.points);
}

class TrackLoader {
  var _sourceJson = {};
  
  String coasterType = "basicSpider";
  Map<String, TrackPart> partDefinitions;
  List<String> sections;

  TrackLoader.fromJson(srcJson)
  {
    this(parse(srcJson));
  }

  TrackLoader(this._sourceJson)
  {
    partDefinitions = new Map<String, TrackPart>();
    for (var tp in _sourceJson['trackParts'])
    {
      partDefinitions[tp['name']] = new TrackPart(tp['name'], tp['trackType'], tp['points'].map(parsePoint));
    }

    sections = _sourceJson['trackElements'];
  }

  static CoasterSplineItem parsePoint(pt)
  {
    Vector3 pos = new Vector3(pt[0],pt[1],pt[2]);
    num rot = 0;
    if (pt.length > 3) rot = pt[3];

    return new CoasterSplineItem(pos, rot);
  }

  TrackLoader.fromURL(url)
  {
    // do something to load the data
    String data = "";
    this(data);    
  }

  List<CoasterSplineItem> get points
  {
    List<CoasterSplineItem> pts = new List<CoasterSplineItem>();
    //CoasterSplineItem currPt = new CoasterSplineItem(new Vector3(50,50,50), 0);
    Quaternion currPos = new Vector3(50,50,50);
    Quaternion currOrient = new Quaternion();
    currOrient.setFromAxisAngle(CoasterSpline.up, Math.PI / 2); // facing forward
    
    // TODO: handle more than 5 points/parts not in 5 pt quantities
    
    
    
    for (String secName in sections)
    {
    
      CoasterSpline partSpline = new CoasterSpline();
      CoasterSplineItem lastPt = null;
      
      for (CoasterSplineItem pt in partDefinitions[secName].points)
      {
        lastPt = pt.rotate(currOrient).offsetPosBy(currPt);
        partSpline.points.add(lastPt);
      }
      //currPt += partDefinitions[secName].points.last;
      currPt = lastPt;
      currOrient = partSpline.getQuaternion(1.0);
    }
    return pts;
  }

  CoasterSpline get spline
  {
    CoasterSpline spl = new CoasterSpline();
    spl.points = this.points;
    return spl;
  }
}


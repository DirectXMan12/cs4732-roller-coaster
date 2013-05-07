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

    for (String elem in sections)
    {
      if (!partDefinitions.containsKey(elem))
      {
        throw "No part named $elem defined in the part type list!";
      }
    }
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
    Vector3 currPos = new Vector3(0,0,0);
    Quaternion currOrient = new Quaternion();
    currOrient.setFromAxisAngle(new Vector3(1,0,0), 0); // facing forward
    
    // TODO: handle more than 5 points/parts not in 5 pt quantities
    
    for (String secName in sections)
    {
      CoasterSpline partSpline = new CoasterSpline();
      CoasterSplineItem lastPt = null;
      
      for (CoasterSplineItem pt in partDefinitions[secName].points)
      {
        lastPt = pt.rotate(currOrient).offsetPosBy(currPos);
        partSpline.points.add(lastPt);
        pts.add(lastPt);
      }
      //currPt += partDefinitions[secName].points.last;
      currPos = lastPt.position; 
      currOrient = partSpline.getQuaternion(1.0);
    }
    return pts;
  }

  List<CoasterSpline> get splines
  {
    List<CoasterSpline> spls = new List<CoasterSpline>();
    List<CoasterSplineItem> totalpts = this.points;
    CoasterSpline currSpline = new CoasterSpline();
    for (var i = 0; i < totalpts.length; i++)
    {
      currSpline.points.add(totalpts[i]);
      if (currSpline.points.length > 4)
      {
        spls.add(currSpline);
        currSpline = new CoasterSpline();
      }
    }
    return spls;
  }
}


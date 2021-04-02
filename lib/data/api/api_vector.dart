import 'dart:math';
import 'package:sonr_app/theme/theme.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:sonr_core/sonr_core.dart';

const double K_RADIUS = 2.0;
const double K_DISTANCE = 5.0;

class VectorPosition {
  // # Reference
  final Position data;

  // @ Direction Facing
  double facing;
  double get radFacing => (facing * pi) / 180.0;
  Vector3 get posFacing => Vector3(K_DISTANCE * cos(radFacing), 0.0, K_DISTANCE * sin(radFacing));
  Sphere get sphereFacing => Sphere.centerRadius(posFacing, K_RADIUS);
  Matrix4 get rotoFacing => Matrix4.rotationY(radFacing);
  Ray get rayFacing => Ray.originDirection(Vector3.zero(), rotoFacing.transform3(Vector3(0, 0, K_DISTANCE)));

  // @ Direction Heading
  double heading;
  double get radHeading => (heading * pi) / 180.0;
  Vector3 get posHeading => Vector3(K_DISTANCE * cos(radHeading), 0.0, K_DISTANCE * sin(radHeading));
  Sphere get sphereHeading => Sphere.centerRadius(posHeading, K_RADIUS);
  Matrix4 get rotoHeading => Matrix4.rotationY(radHeading);
  Ray get rayHeading => Ray.originDirection(Vector3.zero(), rotoHeading.transform3(Vector3(0, 0, K_DISTANCE)));

  // @ Direction Anitpodal Facing
  double antiFacing;
  double get radAntiFacing => (antiFacing * pi) / 180.0;
  Vector3 get posAntiFacing => Vector3(K_DISTANCE * cos(radAntiFacing), 0.0, K_DISTANCE * sin(radAntiFacing));
  Sphere get sphereAntiFacing => Sphere.centerRadius(posAntiFacing, K_RADIUS);
  Matrix4 get rotoAntiFacing => Matrix4.rotationY(radAntiFacing);
  Ray get rayAntiFacing => Ray.originDirection(Vector3.zero(), rotoAntiFacing.transform3(Vector3(0, 0, K_DISTANCE)));

  // @ Direction Anitpodal Heading
  double antiHeading;
  double get radAntiHeading => (antiHeading * pi) / 180.0;
  Vector3 get posAntiHeading => Vector3(K_DISTANCE * cos(radAntiHeading), 0.0, K_DISTANCE * sin(radAntiHeading));
  Sphere get sphereAntiHeading => Sphere.centerRadius(posAntiHeading, K_RADIUS);
  Matrix4 get rotoAntiHeading => Matrix4.rotationY(radAntiHeading);
  Ray get rayAntiHeading => Ray.originDirection(Vector3.zero(), rotoAntiHeading.transform3(Vector3(0, 0, K_DISTANCE)));

  // Rotation
  double xRoto;
  double yRoto;
  double zRoto;

  // # Factory Constructer from Direction Quadruple
  factory VectorPosition.fromQuadruple(Quadruple<double, double, Position_Accelerometer, Position_Gyroscope> data) {
    // Initialize
    double antiFacing;
    double antiHeading;

    // Set Anti Facing
    if (data.item1 < 180) {
      antiFacing = 180 - data.item1;
    } else {
      antiFacing = data.item1 - 180;
    }

    // Set Anti Heading
    if (data.item2 < 180) {
      antiHeading = 180 - data.item2;
    } else {
      antiHeading = data.item2 - 180;
    }

    // Return Position
    return VectorPosition(Position(
        facing: data.item1,
        heading: data.item2,
        accelerometer: data.item3,
        gyroscope: data.item4,
        facingAntipodal: antiFacing,
        headingAntipodal: antiHeading));
  }

  // # Constructer
  VectorPosition(this.data) {
    // Set Direction
    this.facing = data.facing;
    this.heading = data.heading;

    // Set Antipodal
    this.antiFacing = data.facingAntipodal;
    this.antiHeading = data.headingAntipodal;

    // Set Rotation
    this.xRoto = data.gyroscope.x;
    this.yRoto = data.gyroscope.y;
    this.zRoto = data.gyroscope.z;
  }

// ^ Method Checks if Vector Ray intersects with peer sphere
  bool isPointing(VectorPosition user) {
    if (user.intersectsFacing(this)) {
      return true;
    }
    if (user.intersectsAntiFacing(this)) {
      return true;
    }
    return false;
  }

  // ^ Method Checks if Heading Intersects with Facing Sphere
  bool intersectsFacing(VectorPosition receiver) {
    // Check if Heading touches facing
    var headingToFacing = rayHeading.intersectsWithSphere(receiver.sphereFacing);
    if (headingToFacing != null) {
      print("Heading to Facing: " + headingToFacing.toString());
      return true;
    }
    return false;
  }

  // ^ Method Checks if Heading Intersects with Facing Antipodal Sphere
  bool intersectsAntiFacing(VectorPosition receiver) {
    // Check if Heading touches facing
    var headingToAntiFacing = rayHeading.intersectsWithSphere(receiver.sphereAntiFacing);
    if (headingToAntiFacing != null) {
      print("Heading to Anti Facing: " + headingToAntiFacing.toString());
      return true;
    }
    return false;
  }

  // ^ Method Checks if Heading Intersects with Heading Sphere
  bool intersectsHeading(VectorPosition receiver) {
    // Check if Heading touches Heading
    var headingToHeading = rayHeading.intersectsWithSphere(receiver.sphereHeading);
    if (headingToHeading != null) {
      print("Heading to Heading: " + headingToHeading.toString());
      return true;
    }
    return false;
  }

  // ^ Method Checks if Heading Intersects with Heading Antipodal Sphere
  bool intersectsAntiHeading(VectorPosition receiver) {
    // Check if Heading touches facing
    var headingToAntiHeading = rayHeading.intersectsWithSphere(receiver.sphereAntiHeading);
    if (headingToAntiHeading != null) {
      print("Heading to AntiHeading: " + headingToAntiHeading.toString());
      return true;
    }
    return false;
  }

  // ^ Method Returns offset from Another Vector
  Offset offsetFromVector(VectorPosition vector) {
    var diffRad = ((vector.heading - this.antiFacing).abs() * pi) / 180.0;
    var adjDesig = (((vector.heading - this.facing).abs() / 11.25) + 0.25).toInt();
    var diffDesg = Position_Designation.values[(adjDesig % 32)];

    // Convert Rad to Point on Path
    var path = ZonePathProvider(data.proximity);
    var metrics = path.getPath(Get.size).computeMetrics().elementAt(0);
    var point = diffRad * metrics.length;

    // Get Tanget for Point
    var tangent = metrics.getTangentForOffset(point);
    var calcPos = tangent.position;

    // Top of View
    if (diffDesg == Position_Designation.NNE || diffDesg == Position_Designation.NEbN || diffDesg == Position_Designation.NbE) {
      return Offset(180, data.proximity.topOffset);
    } else if (diffDesg == Position_Designation.NE) {
      return Offset(270, data.proximity.topOffset + 20);
    } else if (diffDesg == Position_Designation.N) {
      return Offset(90, data.proximity.topOffset + 20);
    } else {
      return Offset(calcPos.dx.clamp(0, 340).toDouble(), min(ZonePathProvider.proximityMaxHeight(data.proximity), calcPos.dy).toDouble());
    }
  }

  // # Returns String of Data
  @override
  String toString() {
    return {
      "Facing": {
        "Direction": facing,
        "Radians": radFacing,
        "Position": {
          "X": cos(radFacing),
          "Y": 0,
          "Z": sin(radFacing),
        },
      },
      "Antipodal Facing": {
        "Direction": antiFacing,
        "Radians": radAntiFacing,
        "Position": {
          "X": cos(radAntiFacing),
          "Y": 0,
          "Z": sin(radAntiFacing),
        },
      },
      "Heading": {
        "Direction": heading,
        "Radians": radHeading,
        "Position": {
          "X": cos(radHeading),
          "Y": 0,
          "Z": sin(radHeading),
        },
      },
      "Antipodal Heading": {
        "Direction": antiHeading,
        "Radians": radAntiHeading,
        "Position": {
          "X": cos(radAntiHeading),
          "Y": 0,
          "Z": sin(radAntiHeading),
        },
      },
      "Rotation": {
        "X": xRoto,
        "Y": yRoto,
        "Z": zRoto,
      }
    }.toString();
  }
}

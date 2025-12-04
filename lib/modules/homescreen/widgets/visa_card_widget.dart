import 'package:flutter/material.dart';

class DebitCardWidget extends StatelessWidget {
  const DebitCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(width * 0.05),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
      child: Stack(
        children: [
          // Background vertical lines
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                18,
                (_) => Container(
                  width: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white.withOpacity(0), Colors.grey.withOpacity(0.25), Colors.white.withOpacity(0)],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Main card content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Debit card",
                style: TextStyle(fontSize: width * 0.055, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: height * 0.02),

              // CARD NUMBER
              Text(
                "CARD NUMBER",
                style: TextStyle(fontSize: width * 0.03, fontWeight: FontWeight.w500, color: Colors.black54),
              ),
              SizedBox(height: height * 0.005),

              Container(
                padding: EdgeInsets.symmetric(vertical: height * 0.008, horizontal: width * 0.04),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  "••••   ••••   ••••   ••••",
                  style: TextStyle(fontSize: width * 0.065, letterSpacing: 2, fontWeight: FontWeight.w600),
                ),
              ),

              SizedBox(height: height * 0.02),

              Row(
                children: [
                  // Expires
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "EXPIRES",
                          style: TextStyle(fontSize: width * 0.03, color: Colors.black54),
                        ),
                        SizedBox(height: height * 0.005),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: height * 0.008, horizontal: width * 0.04),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            "••/•",
                            style: TextStyle(fontSize: width * 0.05, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: width * 0.04),

                  // CVV
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "CVV",
                          style: TextStyle(fontSize: width * 0.03, color: Colors.black54),
                        ),
                        SizedBox(height: height * 0.005),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: height * 0.008, horizontal: width * 0.04),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            "•••",
                            style: TextStyle(fontSize: width * 0.05, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: height * 0.03),
            ],
          ),

          // Eye icon bubble
          Positioned(
            right: width * 0.18,
            top: height * 0.11,
            child: Container(
              padding: EdgeInsets.all(width * 0.025),
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Icon(Icons.remove_red_eye_outlined, size: width * 0.07, color: Colors.purple),
            ),
          ),

          // VISA logo
          Positioned(
            right: 0,
            bottom: 0,
            child: Text(
              "VISA",
              style: TextStyle(fontSize: width * 0.09, fontWeight: FontWeight.w900, color: Colors.indigo[900]),
            ),
          ),

          // Arrow icon
          Positioned(
            right: 0,
            top: height * 0.005,
            child: Icon(Icons.arrow_forward_ios, size: width * 0.05, color: Colors.black45),
          ),
        ],
      ),
    );
  }
}

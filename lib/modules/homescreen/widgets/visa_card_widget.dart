import 'package:flutter/material.dart';

class DebitCardWidget extends StatefulWidget {
  const DebitCardWidget({super.key});

  @override
  State<DebitCardWidget> createState() => _DebitCardWidgetState();
}

class _DebitCardWidgetState extends State<DebitCardWidget> {
  bool showNumbers = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final w = constraints.maxWidth;
        final h = w * 0.62;

        return Container(
          width: w,
          height: h,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              colors: [Color(0xffe5eef2), Color(0xfff5f8fa)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,

            children: [
              // ------------------------------------------------
              // 🎚 FIXED Vertical Stripes (NO OVERFLOW)
              // ------------------------------------------------
              Positioned(
                top: 16,
                bottom: 16,
                left: w * 0.28, // responsive
                right: w * 0.14, // responsive
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
                          colors: [
                            Colors.white.withOpacity(0),
                            Colors.white.withOpacity(0.28),
                            Colors.white.withOpacity(0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ------------------------------------------------
              // 🌟 Card Content
              // ------------------------------------------------
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,

                children: [
                  const Text(
                    "Debit card",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xff253238)),
                  ),

                  const SizedBox(height: 16),

                  Text("CARD NUMBER", style: TextStyle(color: Colors.grey.shade700, letterSpacing: 1.3, fontSize: 12)),
                  const SizedBox(height: 4),

                  _roundedField(showNumbers ? "4312 5548 9988 1123" : "••••  ••••  ••••  ••••"),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "EXPIRES",
                              style: TextStyle(color: Colors.grey.shade700, letterSpacing: 1.2, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            _roundedField(showNumbers ? "04/27" : "••/••"),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "CVV",
                              style: TextStyle(color: Colors.grey.shade700, letterSpacing: 1.2, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            _roundedField(showNumbers ? "842" : "•••"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // 👁 Eye Button
              Positioned(
                right: 16,
                top: h * 0.33,
                child: GestureDetector(
                  onTap: () => setState(() => showNumbers = !showNumbers),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 18,
                    child: Icon(showNumbers ? Icons.visibility : Icons.visibility_off, color: Colors.deepPurple),
                  ),
                ),
              ),

              // ➡ Arrow Top Right
              const Positioned(right: 10, top: 10, child: Icon(Icons.arrow_forward, color: Colors.black87)),

              // VISA Logo
              Positioned(
                bottom: 10,
                right: 10,
                child: Text(
                  "VISA",
                  style: TextStyle(fontSize: w * 0.12, fontWeight: FontWeight.bold, color: const Color(0xff11307E)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ------------------------------------------------
  // 🔄 Rounded Input Field
  // ------------------------------------------------
  Widget _roundedField(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(40)),
      child: Text(text, style: const TextStyle(fontSize: 17, letterSpacing: 2, fontWeight: FontWeight.bold)),
    );
  }
}

// import 'package:flutter/material.dart';

// class DebitCardWidget extends StatelessWidget {
//   const DebitCardWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final width = MediaQuery.of(context).size.width;
//     final height = MediaQuery.of(context).size.height;

//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(width * 0.05),
//       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
//       child: Stack(
//         children: [
//           // Background vertical lines
//           Positioned.fill(
//             left: 100,
//             right: 50,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: List.generate(
//                 18,
//                 (_) => Container(
//                   width: 2,
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                       colors: [Colors.white.withOpacity(0), Colors.grey.withOpacity(0.25), Colors.white.withOpacity(0)],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),

//           // Main card content
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "Debit card",
//                 style: TextStyle(fontSize: width * 0.055, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: height * 0.02),

//               // CARD NUMBER
//               Text(
//                 "CARD NUMBER",
//                 style: TextStyle(fontSize: width * 0.03, fontWeight: FontWeight.w500, color: Colors.black54),
//               ),
//               SizedBox(height: height * 0.005),

//               Container(
//                 padding: EdgeInsets.symmetric(vertical: height * 0.008, horizontal: width * 0.04),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.9),
//                   borderRadius: BorderRadius.circular(14),
//                 ),
//                 child: Text(
//                   "••••   ••••   ••••   ••••",
//                   style: TextStyle(fontSize: width * 0.065, letterSpacing: 2, fontWeight: FontWeight.w600),
//                 ),
//               ),

//               SizedBox(height: height * 0.02),

//               Row(
//                 children: [
//                   // Expires
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           "EXPIRES",
//                           style: TextStyle(fontSize: width * 0.03, color: Colors.black54),
//                         ),
//                         SizedBox(height: height * 0.005),
//                         Container(
//                           padding: EdgeInsets.symmetric(vertical: height * 0.008, horizontal: width * 0.04),
//                           decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(0.9),
//                             borderRadius: BorderRadius.circular(14),
//                           ),
//                           child: Text(
//                             "••/•",
//                             style: TextStyle(fontSize: width * 0.05, fontWeight: FontWeight.w600),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   SizedBox(width: width * 0.04),

//                   // CVV
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           "CVV",
//                           style: TextStyle(fontSize: width * 0.03, color: Colors.black54),
//                         ),
//                         SizedBox(height: height * 0.005),
//                         Container(
//                           padding: EdgeInsets.symmetric(vertical: height * 0.008, horizontal: width * 0.04),
//                           decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(0.9),
//                             borderRadius: BorderRadius.circular(14),
//                           ),
//                           child: Text(
//                             "•••",
//                             style: TextStyle(fontSize: width * 0.05, fontWeight: FontWeight.w600),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),

//               SizedBox(height: height * 0.03),
//             ],
//           ),

//           // Eye icon bubble
//           Positioned(
//             right: width * 0.18,
//             top: height * 0.11,
//             child: Container(
//               padding: EdgeInsets.all(width * 0.025),
//               decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
//               child: Icon(Icons.remove_red_eye_outlined, size: width * 0.07, color: Colors.purple),
//             ),
//           ),

//           // VISA logo
//           Positioned(
//             right: 0,
//             bottom: 0,
//             child: Text(
//               "VISA",
//               style: TextStyle(fontSize: width * 0.09, fontWeight: FontWeight.w900, color: Colors.indigo[900]),
//             ),
//           ),

//           // Arrow icon
//           Positioned(
//             right: 0,
//             top: height * 0.005,
//             child: Icon(Icons.arrow_forward_ios, size: width * 0.05, color: Colors.black45),
//           ),
//         ],
//       ),
//     );
//   }
// }

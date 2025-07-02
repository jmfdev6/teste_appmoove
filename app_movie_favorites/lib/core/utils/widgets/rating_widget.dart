import 'package:flutter/material.dart';

class RatingWidget extends StatefulWidget {
  final int movieId;
  final double? initialRating;
  final Function(double) onRatingUpdate;
  
  const RatingWidget({
    super.key,
    required this.movieId,
    this.initialRating,
    required this.onRatingUpdate,
  });
  
  @override
  _RatingWidgetState createState() => _RatingWidgetState();
}

class _RatingWidgetState extends State<RatingWidget> {
  double _rating = 0;
  
  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating ?? 0;
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sua Avaliação',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        
        Row(
          children: [
            ...List.generate(5, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _rating = (index + 1).toDouble();
                  });
                  widget.onRatingUpdate(_rating);
                },
                child: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 32,
                ),
              );
            }),
            
            SizedBox(width: 12),
            
            if (_rating > 0)
              Text(
                '${_rating.toInt()}/5',
                style: Theme.of(context).textTheme.titleMedium,
              ),
          ],
        ),
        
        SizedBox(height: 8),
        
        if (_rating > 0)
          TextButton(
            onPressed: () {
              setState(() {
                _rating = 0;
              });
              widget.onRatingUpdate(0);
            },
            child: Text('Remover avaliação'),
          ),
      ],
    );
  }
}
1. Image Data Path (Top Stream)
Step 1: Raw Dataset Input
Raw abdominal image dataset is used as input.

Step 2: Data Preprocessing
Enhancement technique applied to improve image quality for better feature extraction.

Step 3: Data Augmentation
To increase the size and diversity of training data using:
Rotating
Flipping
Scaling
Transpose-based transformations

Step 4: Feature Extraction with Pretrained DL Models
Pretrained models used for deep feature extraction:
ResNet-50
ResNet-101
DenseNet-201
Inception V3
DarkNet-53

Step 5: Transfer Learning
Transfer learning adapts the pretrained models to abdominal dataset.
Extracts feature vectors from images using fine-tuned deep networks.

2. Clinical Data Path (Bottom Stream)

Step 1: Clinical Raw Data Input
Includes metadata like age, symptoms, previous history, etc.

Step 2: Data Preprocessing
Removes corrupted/incomplete entries.
Handles missing values using appropriate imputation.
Normalizes and standardizes the data for consistency.

Step 3: Clinical Text Feature Extraction
Uses BERT (Bidirectional Encoder Representations from Transformers).
Converts clinical notes/text into numerical feature vectors.

3. Multimodal Feature Fusion

Combines:
Image-based feature vector
Clinical text-based feature vector
Creates a unified feature set representing both visual and clinical insights.

4. Classification
Uses multiple machine learning classifiers to label the data:
Fine Tree
Cubic SVM
Subspace Discriminant
Subspace KNN

5. Evaluation
Two evaluation strategies are applied:
End-to-End Evaluation of deep learning models.
Classifier-based evaluation after feature fusion.

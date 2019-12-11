#!/bin/bash
cd /home/ec2-user/SageMaker

aws s3 cp s3://rs-data-jupyter/multi_label_text_classification_genre.ipynb .
aws s3 cp s3://rs-data-jupyter/multi_label_text_classification_genre_exec.ipynb .
aws s3 cp s3://rs-data-jupyter/language_identification.ipynb .
aws s3 cp s3://rs-data-jupyter/language_identification_exec.ipynb .


sudo -u ec2-user -i <<'EOF'
source activate JupyterSystemEnv
cd /home/ec2-user/SageMaker
jupyter nbconvert --ExecutePreprocessor.timeout=-1 --to notebook --execute multi_label_text_classification_genre_exec.ipynb --stdout &
jupyter nbconvert --ExecutePreprocessor.timeout=-1 --to notebook --execute language_identification_exec.ipynb --stdout &

source deactivate 
EOF

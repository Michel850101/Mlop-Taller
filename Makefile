install:
	pip install --upgrade pip && \
	pip install -r requirements.txt

format:
	black . --exclude venv || true

train:
	python train.py

eval:
	echo "## Model Metrics" > report.md
	cat ./Results/metrics.txt >> report.md
	echo '\n## Confusion Matrix Plot' >> report.md
	echo '![Confusion Matrix](./Results/model_results.png)' >> report.md
	cml comment create report.md

update-branch:
	git config --global user.name $(USER_NAME)
	git config --global user.email $(USER_EMAIL)
	git commit -am "Update with new results"
	git push --force origin HEAD:update

hf-login:
	pip install -U "huggingface_hub[cli]"
	git pull origin main
	git switch main
	huggingface-cli login --token $(HF) --add-to-git-credential

push-hub:
	huggingface-cli upload Michel850101/Drug-Classification ./app.py app.py --repo-type=space --commit-message="Upload app"
	huggingface-cli upload Michel850101/Drug-Classification ./requirements.txt requirements.txt --repo-type=space --commit-message="Upload requirements"
	huggingface-cli upload Michel850101/Drug-Classification ./Model --repo-type=space --commit-message="Sync Model"
	huggingface-cli upload Michel850101/Drug-Classification ./Results --repo-type=space --commit-message="Sync Results"

deploy: hf-login push-hub

all: install format train eval update-branch deploy
name: deploy
on:
  workflow_dispatch:
     inputs:
        ENV:
            description: 'ENV'
            required: true
            default: 'poc'
env:
  ENV: ${{ github.event.inputs.ENV }}
  GKE_SA_KEY: ${{ secrets.GKE_SA_KEY }}
  GKE_CLUSTER: ${{ vars.GKE_CLUSTER }}
  PX_CLOUD_CLUSTER: ${{ vars.PX_CLOUD_CLUSTER }}
  GKE_ZONE : ${{ vars.GKE_ZONE }}
  PROJECT_ID:  ${{ vars.PROJECT_ID }}
  APP_NAME : zerok-cli
  PX_API_KEY: ${{ secrets.PX_API_KEY }}
  PX_CLUSTER_NAME: ${{ vars.PX_CLUSTER_NAME }}
  PX_DEPLOYMENT_KEY: ${{ secrets.PX_DEPLOYMENT_KEY }}

  
jobs:
  deploy:
    environment: ${{ github.event.inputs.ENV }}
    runs-on: self-hosted
    steps:
      - name: Checkout
        uses: actions/checkout@v3 
      - id: 'auth'
        name: 'Authenticate to Google Cloud'
        uses: 'google-github-actions/auth@v0'
        with:
          credentials_json: '${{ env.GKE_SA_KEY }}'
        

      - uses: google-github-actions/setup-gcloud@v0
        with:
          version: latest
          export_default_credentials: true
      

      - id: 'get-credentials'
        uses: 'google-github-actions/get-gke-credentials@v1'
        with:
           cluster_name: '${{ env.GKE_CLUSTER }}'
           location: '${{ env.GKE_ZONE }}'

   
      
      - name: Set up helm
        run: |-
           curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
           chmod 700 get_helm.sh
           ./get_helm.sh
  

      - name: Deploy
        run: |-
            ./run.sh PX_CLUSTER_NAME=$PX_CLUSTER_NAME PX_CLOUD_CLUSTER=$PX_CLOUD_CLUSTER PX_API_KEY=$PX_API_KEY PX_DEPLOYMENT_KEY=$PX_DEPLOYMENT_KEY

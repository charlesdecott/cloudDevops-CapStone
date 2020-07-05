FROM nginx

## Step 1:
# Copy the capstone folder to the /usr/share/nginx/html
COPY index.html /usr/share/nginx/html/index.html

## Step 2:
# Expose port 80
EXPOSE 80

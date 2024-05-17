from functools import wraps
from django.shortcuts import redirect

def custom_login_required(view_func):
    @wraps(view_func)
    def wrapper(request, *args, **kwargs):
        # Check if the user is authenticated
        if 'email' in request.session:
            # User is authenticated, allow the view function to execute
            return view_func(request, *args, **kwargs)
        else:
            # User is not authenticated, redirect to the login page
            return redirect("/login/")  # Update the URL as per your login page URL

    return wrapper
module ivan.ifs3d.keysstate;

private import glfw;

class KeysState {
	this(bool topLevel = true) {
		if(topLevel == true) {
			old = new KeysState(false);
		}
	}

	package {
		KeysState old;

		bool lCtrl = false;
		bool lShift = false;
		bool lAlt = false;
		bool Left = false;
		bool Right = false;
		bool Up = false;
		bool Down = false;
		bool insert = false, del = false;

		int pressed = 0;
	}

	void update(int key, int action) {
		this.old.lCtrl = this.lCtrl;
		this.old.lShift = this.lShift;
		this.old.Left = this.Left;
		this.old.Right = this.Right;

		this.pressed = action;

		if(action == GLFW_PRESS) {
			switch(key) {
				case GLFW_KEY_LCTRL:
					this.lCtrl = true;
				break;
				case GLFW_KEY_LSHIFT:
					this.lShift = true;
				break;
				case GLFW_KEY_LALT:
					this.lAlt = true;
				break;
				case GLFW_KEY_LEFT:
					this.Left = true;
				break;
				case GLFW_KEY_RIGHT:
					this.Right = true;
				break;
				case GLFW_KEY_UP:
					this.Up = true;
				break;
				case GLFW_KEY_DOWN:
					this.Down = true;
				break;
				case GLFW_KEY_INSERT:
					this.insert = true;
				break;
				case GLFW_KEY_DEL:
					this.del = true;
				break;
				default:
				break;
			}
		} else if(action == GLFW_RELEASE) {
			switch(key) {
				case GLFW_KEY_LCTRL:
					this.lCtrl = false;
				break;
				case GLFW_KEY_LSHIFT:
					this.lShift = false;
				break;
				case GLFW_KEY_LALT:
					this.lAlt = false;
				break;
				case GLFW_KEY_LEFT:
					this.Left = false;
				break;
				case GLFW_KEY_RIGHT:
					this.Right = false;
				break;
				case GLFW_KEY_UP:
					this.Up = false;
				break;
				case GLFW_KEY_DOWN:
					this.Down = false;
				break;
				case GLFW_KEY_INSERT:
					this.insert = false;
				break;
				case GLFW_KEY_DEL:
					this.del = false;
				break;
				default:
				break;
			}
		}
	}
}

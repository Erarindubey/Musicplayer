# MusicPlayer Visualization Challenge

## 🧾Project summary:
A high-performance Flutter application designed to render and interact with a dataset of 50,000+ music tracks. Built with **BLoC Architecture**, **Custom Infinite Scrolling**, and the **iTunes Search API**.



<img width="572" height="976" alt="image" src="https://github.com/user-attachments/assets/d092a5a4-bbc6-4510-85ba-6485f7735097" />

## 📺Demo Video:
**[https://drive.google.com/file/d/18yu1K85W8-KXtOo6ZVgkA4iu5roEzpUr/view?usp=drive_link]**
*contains everything regarding smooth scrolling and pagination*
---
## 🔑Key Features:

- **Infinite Scrolling:** Capable of rendering 50,000+ items without performance degradation using `ListView.builder` and standard virtualization.
- **Search Optimization:** Debounced search input (500ms) to prevent API spamming and UI jank.
- **Robust Error Handling:** Explicit "NO INTERNET CONNECTION" states for both list and detail views.
- **HD Image Handling:** Custom logic to fetch high-resolution artwork (600x600) from standard API responses.
- **Lyrics Integration:** Fetches synchronized or plain lyrics using the LRCLIB API.
---

## 🧱Bloc Pattern:
The app follows a strict **BLoC (Business Logic Component)** architecture to separate UI from business logic.

### **1. Events (`TrackEvent`)**
- `FetchTracks`: Triggered when the user scrolls to the bottom (90%) of the list. Loads the next "page" of data.
- `SearchTracks`: Triggered when the user types in the search bar. Resets the list and fetches new data based on the query.

### **2. States (`TrackState`)**
- `initial`: App start state.
- `loading`: Shows a `CircularProgressIndicator` while fetching data.
- `success`: Contains the `List<Track>` data to be rendered.
- `failure`: Stores error messages (e.g., "NO INTERNET CONNECTION").

### **3. Data Flow**
1.  **UI** (LibraryScreen) dispatches `FetchTracks` via `ScrollController`.
2.  **BLoC** checks if `hasReachedMax` is true. If not, it calls the Repository.
3.  **Repository** fetches data from iTunes API, parses JSON, and returns `List<Track>`.
4.  **BLoC** emits a new `TrackState` with the appended list.
5.  **UI** rebuilds only the necessary widgets.

---

## 💭Major Decisions:

### **1 API Migration:**
**Constraint:**: The document had suggested to use the `Deezer Api`.

**Conflict:**: The `deezer api` is geo-blocked in `India` that makes it mostly impossible to retreieve data from api without a `Vpn`.

**Resolution:**: The `Itunes Api` is free and functions similary like `Deezer`, because it has similar functionality and same data output so the response given by `Itunes api` was accurate and reliable and was the reason that i used it instead of `Deezer`.



<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/2e507e44-50a7-4aef-a2b1-cc79ae43c888" />




### **2 Omission of client-side A-Z Grouping**
**Constraint**: The document had requested that the `Flutter` application should have `A-Z Grouping` with sticky headers.

**Conflict**: The `Itunes Api` returns results sorted by **Relevance** (popularity) not Alphabetically. To Group them and sort in A-Z format, all 50k songs must be loaded at once into memory.

**Resolution:** Loading 50k objects into RAM at startup violates the "Stable Memory Usage" and "Quick Startup" requirements. I prioritized **performance** and **infinite scrolling** over sorting. I simulated directory-style diversity by fetching tracks from an alphabetical list of famous artists (A-Z) in the repository.


<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/690f14a5-5e62-414c-b82e-00423ab56d4e" />



### **3. Image Resolution "Hack"**
**Constraint:** The API returns low-quality 100x100 thumbnails (`artworkUrl100`).

**Conflict:** The Details screen requires a high-quality hero image (300x300+).

**Resolution:** I implemented a string manipulation utility in the `Track` model to replace `100x100` with `600x600` in the URL. This accesses the high-res assets stored on Apple's servers without needing a different API endpoint.

---
## 🛠️ Issue Faced & Fix
**Issue:**
When implementing the infinite scroll, rapid scrolling caused the `FetchTracks` event to fire dozens of times per second, leading to API rate limiting and UI stutter ("jank").

**Fix:**
I implemented an **Event Transformer** with `throttleTime` (for scrolling) and `debounceTime` (for search) in the BLoC.
- **Scroll:** Ignores new fetch events for 500ms after a trigger.
- **Search:** Waits for the user to stop typing for 500ms before making a request.
*Result: 60FPS scrolling performance and reduced network load.*


<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/91c89dea-c467-4c3e-85a6-3425b38aafce" />


---

## ❓ What Breaks at 100,000 Items?
**Current Limitation:**
Currently, the app stores the fetched list in a Dart `List<Track>` in memory.
- At **50,000 items**, memory usage is acceptable (~54MB for data models).
- At **100,000+ items**, the memory footprint would grow linearly, eventually causing an **OOM (Out of Memory) crash** on lower-end devices.

## Future Optimization (Next Steps)
**Problems:**
*Could'nt implement grouping due to API structure.*

**Solution:**
*A self customized API that will be connected to a DataBase which will help in solving Grouping issues as well as loading of 100k songs will be possible as well.* 

## Memory usage:
### Memory Evidence
**[https://drive.google.com/file/d/1sCf1hrE1Fqe-bgYgO_GJxMHImHG3wkb5/view?usp=drive_link]**

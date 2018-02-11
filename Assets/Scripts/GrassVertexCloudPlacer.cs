using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//[ExecuteInEditMode]
public class GrassVertexCloudPlacer : MonoBehaviour {

    private Mesh meshForPlacingGrass;
    public MeshFilter meshFilter;

    public int randomSeed;
    public Vector2 sizeOfField;

    [Range(0, 60000)]
    public int numberOfTufts = 60000;

    public float maxHeight = 1000;
    public float grassGroundOffset = -14.0f;

    private List<Matrix4x4> tuftMatrices;
    private Vector3 lastPosition;

	// Update is called once per frame
	void Update ()
    {
        if (lastPosition != transform.position)
        {
                Random.InitState(randomSeed);

            List<Vector3> vertices = new List<Vector3>(numberOfTufts);
            //int[] indices = new int[numberOfTufts];
            List<int> indices = new List<int>(numberOfTufts);
            List<Color> colors = new List<Color>(numberOfTufts);
            List<Vector3> normals = new List<Vector3>(numberOfTufts);

            int vertexCount = 0;
            for (int i = 0; i < numberOfTufts; ++i)
            {
                Vector3 origin = new Vector3();
                origin = transform.position;
                

                origin.y = maxHeight;
                origin.x += sizeOfField.x * Random.Range(-0.5f, 0.5f);
                origin.z += sizeOfField.y * Random.Range(-0.5f, 0.5f);

                Ray discoveryRay = new Ray(origin, Vector3.down);
                RaycastHit hitInfo;

                if (Physics.Raycast(discoveryRay, out hitInfo, maxHeight))
                {
                    // will create a vertex if the ray has hit the terrain, not trees (these need to be set to a proper layer for this to work!)
                    if (hitInfo.transform.gameObject.layer == LayerMask.NameToLayer("Terrain"))
                    {
                        origin = hitInfo.point;
                        origin.y += grassGroundOffset;
                        origin.x -= this.transform.position.x;
                        origin.z -= this.transform.position.z;

                        vertices.Add(origin);
                        //indices[i] = i;
                        indices.Add(vertexCount);
                        colors.Add(new Color(Random.Range(0.0f, 1.0f), Random.Range(0.0f, 1.0f), Random.Range(0.0f, 1.0f), 1));
                        normals.Add(hitInfo.normal);
                        vertexCount++;
                    }


                    
                }
            }
            //while (vertices.Count % 3 != 0)
            //{
            //    // remove last vertex
            //    vertices.RemoveAt(vertices.Count - 1);
            //    indices.RemoveAt(vertices.Count - 1);
            //    colors.RemoveAt(vertices.Count - 1);
            //    normals.RemoveAt(vertices.Count - 1);
            //}

            //vertices.RemoveRange(vertexCount, vertices.Count);
            //indices.RemoveRange(vertexCount, indices.Count);
            //colors.RemoveRange(vertexCount, colors.Count);
            //normals.RemoveRange(vertexCount, normals.Count);

            meshForPlacingGrass = new Mesh();
            meshForPlacingGrass.Clear();
            meshForPlacingGrass.SetVertices(vertices);
            meshForPlacingGrass.SetIndices(indices.ToArray(), MeshTopology.Points, 0, false);
            meshForPlacingGrass.SetColors(colors);
            meshForPlacingGrass.SetNormals(normals);

            meshFilter.mesh = meshForPlacingGrass;

            lastPosition = transform.position;

        }
    }
}
